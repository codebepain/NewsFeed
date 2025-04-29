//
//  News.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 24.04.2025.
//

import Foundation

struct News {
    let id: Int
    let title: String
    let description: String
    let publishedDate: Date
    let fullURL: URL
    let imageURL: URL?
    let category: String
}

protocol NewsDomainMapperProtocol {
    func map(item: NewsItem) throws -> News
}

struct NewsDomainMapper: NewsDomainMapperProtocol {
    
    enum MappingError: Error {
        case invalidData
    }
    
    func map(item: NewsItem) throws -> News {
        guard
            let publishedDate = DateFormatter.utc.date(from: item.publishedDate),
            let fullURL = URL(string: item.fullUrl)
        else {
            throw MappingError.invalidData
        }
        
        return News(
            id: item.id,
            title: item.title,
            description: item.description,
            publishedDate: publishedDate,
            fullURL: fullURL,
            imageURL: URL(string: item.titleImageUrl),
            category: item.categoryType
        )
    }
}
