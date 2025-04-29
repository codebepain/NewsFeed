//
//  DependencyContainer.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation

final class DependencyContainer {
    // Костыль для возможности регистрировать зависимость с передачей аргумента
    private struct TypePairKey: Hashable {
        let serviceType: ObjectIdentifier
        let argumentType: ObjectIdentifier
        
        init(serviceType: Any.Type, argumentType: Any.Type) {
            self.serviceType = ObjectIdentifier(serviceType)
            self.argumentType = ObjectIdentifier(argumentType)
        }
    }
    
    private var services: [ObjectIdentifier: Any] = [:]
    private var servicesWithArgs: [TypePairKey: Any] = [:]
    
    func register<Service>(
        _ type: Service.Type,
        service: @escaping (DependencyContainer) throws -> Service
    ) {
        services[ObjectIdentifier(type)] = service
    }
    
    func register<Service, Argument>(
        _ type: Service.Type,
        argument: Argument.Type,
        service: @escaping (DependencyContainer, Argument) throws -> Service
    ) {
        let key = TypePairKey(serviceType: type, argumentType: argument)
        servicesWithArgs[key] = service
    }
    
    func resolve<Service>(_ type: Service.Type) -> Service {
        let key = ObjectIdentifier(type)
        
        guard let service = services[key] as? (DependencyContainer) throws -> Service else {
            fatalError("No registration found for type: \(type)")
        }
        
        do {
            return try service(self)
        } catch {
            fatalError("Failed to resolve \(type): \(error)")
        }
    }
    
    func resolve<Service, Argument>(_ type: Service.Type, argument: Argument) -> Service {
        let key = TypePairKey(serviceType: type, argumentType: Argument.self)
        
        guard let service = servicesWithArgs[key] as? (DependencyContainer, Argument) throws -> Service else {
            fatalError("No registration found for \(type) with argument \(Argument.self)")
        }
        
        do {
            return try service(self, argument)
        } catch {
            fatalError("Failed to resolve \(type) with argument \(Argument.self): \(error)")
        }
    }
    
    static func configure() -> DependencyContainer {
        let container = DependencyContainer()
        
        container.register(NetworkServiceProtocol.self) { _ in
            NetworkService()
        }
        
        container.register(NewsDomainMapperProtocol.self) { _ in
            NewsDomainMapper()
        }
        
        container.register(NewsServiceProtocol.self) { resolver in
            NewsService(
                networkService: resolver.resolve(NetworkServiceProtocol.self),
                newsMapper: resolver.resolve(NewsDomainMapperProtocol.self)
            )
        }
        
        container.register(CacheStorageProtocol.self) { _ in
            try HybridCacheStorage()
        }
        
        container.register(ImageDownsamplerProtocol.self) { _ in
            ImageDownsampler()
        }
        
        container.register(ImageLoaderProtocol.self) { resolver in
            ImageLoader(
                networkService: resolver.resolve(NetworkServiceProtocol.self),
                cache: resolver.resolve(CacheStorageProtocol.self),
                downsampler: resolver.resolve(ImageDownsamplerProtocol.self)
            )
        }
        
        container.register((any NewsListViewModelProtocol).self) { resolver in
            NewsListViewModel(
                newsService: resolver.resolve(NewsServiceProtocol.self),
                imageLoader: resolver.resolve(ImageLoaderProtocol.self)
            )
        }
        
        container.register(
            (any NewsDetailViewModelProtocol).self,
            argument: News.self)
        { _, news in
            NewsDetailViewModel(news: news)
        }
        
        return container
    }
}
