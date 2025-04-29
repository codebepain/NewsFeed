//
//  ImageViewProxy.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 29.04.2025.
//

import UIKit

final class ImageViewProxy {
    private weak var imageView: UIImageView?
    private var loadingTask: Task<Void, Never>?
    private var currentURL: URL?
    
    public init(_ imageView: UIImageView) {
        self.imageView = imageView
    }
    
    func setImage(from url: URL, using loader: ImageLoaderProtocol) {
        cancel()
        guard let imageView else { return }
        
        currentURL = url
        loadingTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                let image = try await loader.loadImage(from: url)
                guard !Task.isCancelled, self.currentURL == url else { return }
                
                await MainActor.run {
                    imageView.alpha = 0
                    imageView.image = image
                    UIView.animate(withDuration: 0.3) {
                        imageView.alpha = 1
                    }
                }
            } catch {
                await MainActor.run { imageView.image = nil }
            }
        }
    }
    
    func cancel() {
        loadingTask?.cancel()
        loadingTask = nil
        currentURL = nil
    }
}

final class AssociatedKey {
    private init() {}
    
    static func key(for name: StaticString = #function) -> UnsafeRawPointer {
        UnsafeRawPointer(Unmanaged.passUnretained(name as AnyObject).toOpaque())
    }
}
