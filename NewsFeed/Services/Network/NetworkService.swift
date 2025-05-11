//
//  NetworkService.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol APIConfiguration {
    var baseURL: URL { get }
    var path: String { get }
}

enum AutodocAPI {
    enum Environment {
        case dev
        
        var baseURL: URL {
            switch self {
            case .dev:
                return URL(string: "https://webapi.autodoc.ru/api")!
            }
        }
    }
    
    case news(page: Int, itemsPerPage: Int)
}

extension AutodocAPI: APIConfiguration {
    var baseURL: URL {
        Environment.dev.baseURL
    }
    
    var path: String {
        switch self {
        case .news(let page, let itemsPerPage):
            return "/news/\(page)/\(itemsPerPage)"
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case underlying(Error)
}

protocol NetworkServiceProtocol: Sendable {
    func performRequest<T: Decodable>(
        endpoint: APIConfiguration,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?
    ) async throws -> T
    
    func performRequest(url: URL) async throws -> Data
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadRevalidatingCacheData
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024
        )
        self.session = URLSession(configuration: config)
        self.decoder = decoder
    }
    
    func performRequest<T: Decodable>(
        endpoint: APIConfiguration,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        var components = URLComponents(
            url: endpoint.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func performRequest(url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        return data
    }
}
