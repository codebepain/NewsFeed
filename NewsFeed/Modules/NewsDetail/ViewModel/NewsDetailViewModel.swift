//
//  NewsDetailViewModel.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation
import Combine

protocol NewsDetailViewModelProtocol: AnyObject, NavigatingViewModel where Step == NewsDetailViewModel.NavigationStep {
    var newsPublisher: AnyPublisher<News, Never> { get }
    func didFinishReading()
}

final class NewsDetailViewModel: NewsDetailViewModelProtocol {
    
    enum NavigationStep {
        case close
    }
    // MARK: - Private properties
    
    @Published private var news: News
    
    private let navigationSubject = PassthroughSubject<NavigationStep, Never>()
    
    // MARK: - Public properties
    
    var navigationStepPublisher: AnyPublisher<NavigationStep, Never> {
        navigationSubject.eraseToAnyPublisher()
    }
    
    var newsPublisher: AnyPublisher<News, Never> {
        $news.eraseToAnyPublisher()
    }
    
    // MARK: - Init
    
    init(news: News) {
        self.news = news
    }
    
    // MARK: - Public methods
    
    func didFinishReading() {
        navigationSubject.send(.close)
    }
}
