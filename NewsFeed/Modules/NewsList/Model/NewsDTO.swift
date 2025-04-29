//
//  News.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation

struct NewsResponse: Codable {
    let news: [NewsItem]
    let totalCount: Int
}

struct NewsItem: Codable, Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let url: String
    let fullUrl: String
    let titleImageUrl: String
    let categoryType: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.publishedDate = try container.decode(String.self, forKey: .publishedDate)
        self.url = try container.decode(String.self, forKey: .url)
        self.fullUrl = try container.decode(String.self, forKey: .fullUrl)
        self.titleImageUrl = try container.decodeIfPresent(String.self, forKey: .titleImageUrl) ?? ""
        self.categoryType = try container.decode(String.self, forKey: .categoryType)
    }
}
