//
//  NewsService.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation

protocol NewsServiceProtocol {
    func fetchNews(page: Int, itemsPerPage: Int) async throws -> [News]
}

final class NewsService: NewsServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let newsMapper: NewsDomainMapperProtocol
    
    init(
        networkService: NetworkServiceProtocol,
        newsMapper: NewsDomainMapperProtocol
    ) {
        self.networkService = networkService
        self.newsMapper = newsMapper
    }
    
    func fetchNews(page: Int, itemsPerPage: Int) async throws -> [News] {
        let response: NewsResponse = try await networkService.performRequest(
            endpoint: AutodocAPI.news(page: page, itemsPerPage: itemsPerPage),
            method: .get,
            queryItems: nil
        )
        return try response.news.map {
            try newsMapper.map(item: $0)
        }
    }
}
