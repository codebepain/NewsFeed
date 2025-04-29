//
//  ImageDownsampler.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 21.04.2025.
//

import UIKit

protocol ImageDownsamplerProtocol {
    func downsample(_ imageData: Data) async throws -> UIImage
}

final class ImageDownsampler: ImageDownsamplerProtocol {
    
    private enum Constants {
        static var maxDimensionInPixels: CGFloat {
            let scale = UIScreen.main.scale
            let screenWidth = UIScreen.main.bounds.width * scale
            return screenWidth
        }
    }
    
    func downsample(_ imageData: Data) async throws -> UIImage {
        try await Task.detached(priority: .userInitiated) {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
                throw ImageLoaderError.badData
            }
            
            let maxDimensionInPixels = Constants.maxDimensionInPixels
            
            let options = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
            
            guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options) else {
                throw ImageLoaderError.badData
            }
            
            let image = UIImage(cgImage: thumbnail)
            return image.preparingForDisplay() ?? image
        }.value
    }
}
