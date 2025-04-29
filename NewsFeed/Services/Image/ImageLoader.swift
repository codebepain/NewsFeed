//
//  ImageLoader.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 21.04.2025.
//

import Foundation
import UIKit

protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage?
}

actor ImageLoader: ImageLoaderProtocol {
    private let networkService: NetworkServiceProtocol
    private let cache: CacheStorageProtocol
    private let downsampler: ImageDownsamplerProtocol
    private var tasks: [URL: Task<UIImage, Error>] = [:]
    
    init(
        networkService: NetworkServiceProtocol,
        cache: CacheStorageProtocol,
        downsampler: ImageDownsamplerProtocol
    ) {
        self.networkService = networkService
        self.cache = cache
        self.downsampler = downsampler
    }
    
    func loadImage(from url: URL) async throws -> UIImage? {
        let key = keyForCache(url)
        if let cachedData = try await cache.data(for: key) {
            return await UIImage(data: cachedData)?.byPreparingForDisplay()
        }
        
        if let existingTask = tasks[url] {
            return try await existingTask.value
        }
        
        let task = Task<UIImage, Error> { [weak self] in
            guard let self else { return UIImage() }
            let imageData = try await networkService.performRequest(url: url)
            let image = try await self.downsampler.downsample(imageData)
            if let data = image.jpegData(compressionQuality: 0.8) {
                try await self.cache.set(data, for: key)
            }
            return image
        }
        
        tasks[url] = task
        defer { tasks[url] = nil }
        
        return try await task.value
    }
    
    private func keyForCache(_ url: URL) -> String {
        url.pathComponents.suffix(2).joined(separator: "_")
    }
}
