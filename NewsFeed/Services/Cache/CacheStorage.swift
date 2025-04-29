//
//  CacheStorage.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation

protocol CacheStorageProtocol {
    func set(_ data: Data, for key: String) async throws
    func data(for key: String) async throws -> Data?
    func remove(for key: String) async throws
    func clear() async throws
}

final class HybridCacheStorage: CacheStorageProtocol {
    private let cache = NSCache<NSString, NSData>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init(
        name: String = "Images",
        countLimit: Int = 100,
        totalCostLimit: Int = 1024 * 1024 * 100
    ) throws {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
        
        guard let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("No access to caches directory")
        }
        cacheDirectory = cachesDirectory.appendingPathComponent(name)
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func set(_ data: Data, for key: String) async throws {
        cache.setObject(data as NSData, forKey: key as NSString)
        
        try await Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            let fileURL = self.cacheDirectory.appendingPathComponent(key)
            try data.write(to: fileURL, options: .atomic)
        }.value
    }
    
    func data(for key: String) async throws -> Data? {
        if let data = cache.object(forKey: key as NSString) as Data? {
            return data
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(key)
        return try await Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else { return nil }
            guard self.fileManager.fileExists(atPath: fileURL.path) else { return nil }
            let data = try Data(contentsOf: fileURL)
            self.cache.setObject(data as NSData, forKey: key as NSString)
            return data
        }.value
    }
    
    func remove(for key: String) async throws {
        cache.removeObject(forKey: key as NSString)
        
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try await Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            if self.fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            }
        }.value
    }
    
    func clear() async throws {
        cache.removeAllObjects()
        
        try await Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            try fileManager.removeItem(at: cacheDirectory)
            try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }.value
    }
}
