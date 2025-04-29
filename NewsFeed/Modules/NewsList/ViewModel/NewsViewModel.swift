//
//  NewsListViewModel.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation
import Combine
import UIKit

protocol NewsListViewModelProtocol: AnyObject,
                                    NavigatingViewModel where Step == NewsListViewModel.NavigationStep {
    
    var newsPublisher: AnyPublisher<[NewsCellModel], Never> { get }
    var loadingPublisher: AnyPublisher<LoadingState, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var imageLoader: ImageLoaderProtocol { get }
    
    func loadNewsIfNeeded(item: NewsCellModel?)
    func prefetchItems(at indices: [Int])
    func cancelPrefetching(at indices: [Int])
    func showSelectedItem(_ model: NewsCellModel)
}

final class NewsListViewModel: NewsListViewModelProtocol {
    
    enum NavigationStep {
        case showNewsDetail(newsItem: News)
    }
    // MARK: - Private properties

    @Published private var news: [News] = []
    @Published private var loadingState: LoadingState = .idle
    @Published private var loadingError: Error? = nil
    
    private let newsService: NewsServiceProtocol
    private let itemsPerPage = 15
    private var currentPage = 1
    private var canLoadMore = true
    
    private lazy var displayDateFormatter = DateFormatter.local
    
    private var prefetchTasks: [Int: Task<Void, Never>] = [:]

    private let navigationSubject = PassthroughSubject<NavigationStep, Never>()
    
    // MARK: - Internal
    let imageLoader: ImageLoaderProtocol
    
    // MARK: - Public properties
    
    var newsPublisher: AnyPublisher<[NewsCellModel], Never> {
        $news.map {
            $0.map(NewsCellModel.init)
        }
        .eraseToAnyPublisher()
    }
    
    var loadingPublisher: AnyPublisher<LoadingState, Never> {
        $loadingState.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<Error?, Never> {
        $loadingError.eraseToAnyPublisher()
    }
    
    var navigationStepPublisher: AnyPublisher<NavigationStep, Never> {
        navigationSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Init
    
    init(newsService: NewsServiceProtocol, imageLoader: ImageLoaderProtocol) {
        self.newsService = newsService
        self.imageLoader = imageLoader
    }
    
    // MARK: - Public methods
    
    func loadNewsIfNeeded(item: NewsCellModel?) {
        guard loadingState == .idle else { return }
        guard let item else {
            Task { await fetchData(isInitialLoad: true) }
            return
        }
        let thresholdIndex = news.count - 5
        if news.firstIndex(where: { $0.id == item.id }) == thresholdIndex,
           canLoadMore {
            currentPage += 1
            Task { await fetchData(isInitialLoad: false) }
        }
    }

    func showSelectedItem(_ model: NewsCellModel) {
        guard let newsItem = news.first(where: { $0.id == model.id }) else { return }
        navigationSubject.send(.showNewsDetail(newsItem: newsItem))
    }
    
    func prefetchItems(at indices: [Int]) {
        for idx in indices {
            guard idx < news.count else { continue }
            let item = news[idx]
            guard prefetchTasks[item.id] == nil else { continue }
            let task = Task { [weak self] in
                guard let self, let url = item.imageURL else { return }
                _ = try? await self.imageLoader.loadImage(from: url)
            }
            prefetchTasks[item.id] = task
        }
    }
    
    func cancelPrefetching(at indices: [Int]) {
        for idx in indices {
            guard idx < news.count else { continue }
            let id = news[idx].id
            prefetchTasks[id]?.cancel()
            prefetchTasks[id] = nil
        }
    }
}

// MARK: - Private methods

private extension NewsListViewModel {
    
    private func fetchData(isInitialLoad: Bool) async {
        loadingState = isInitialLoad ? .initial : .loadingMore
        defer { loadingState = .idle }
        
        do {
            let news = try await newsService.fetchNews(
                page: currentPage,
                itemsPerPage: itemsPerPage
            )
            
            if isInitialLoad {
                self.news = news
            } else {
                self.news += news
            }
            
            canLoadMore = news.count == itemsPerPage
            loadingError = nil
        } catch {
            loadingError = error
        }
    }
}
