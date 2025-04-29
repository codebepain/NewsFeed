//
//  ImageLoader.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 21.04.2025.
//

import Foundation
import UIKit

enum ImageLoaderError: Error {
    case badData
}

protocol ImageLoaderProtocol {
    func loadImage(from url: URL) async throws -> UIImage
}

actor ImageLoader: ImageLoaderProtocol {
    private let networkService: NetworkServiceProtocol
    private let cache: CacheStorageProtocol
    private let downsampler: ImageDownsamplerProtocol
    private var tasks: [String: Task<UIImage, Error>] = [:]
    
    init(
        networkService: NetworkServiceProtocol,
        cache: CacheStorageProtocol,
        downsampler: ImageDownsamplerProtocol
    ) {
        self.networkService = networkService
        self.cache = cache
        self.downsampler = downsampler
    }
    
    func loadImage(from url: URL) async throws -> UIImage {
        let urlString = url.absoluteString
        if let cachedData = try await cache.data(for: urlString) {
            return await Task.detached(priority: .userInitiated) {
                UIImage(data: cachedData)?.preparingForDisplay() ?? UIImage()
            }.value
        }
        
        if let existingTask = tasks[urlString] {
            return try await existingTask.value
        }
        
        let task = Task<UIImage, Error> { [weak self] in
            guard let self else { return UIImage() }
            let imageData = try await networkService.performRequest(url: url)
            let image = try await self.downsampler.downsample(imageData)
            if let data = image.jpegData(compressionQuality: 0.8) {
                try await self.cache.set(data, for: urlString)
            }
            return image
        }
        
        tasks[urlString] = task
        defer { tasks[urlString] = nil }
        
        return try await task.value
    }
}
