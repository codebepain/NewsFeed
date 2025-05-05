//
//  NewsDetailViewModel.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Foundation
import Combine

protocol NewsDetailViewModelProtocol: AnyObject, NavigatingViewModel where Step == NewsDetailViewModel.NavigationStep {
    var requestPublisher: AnyPublisher<URLRequest, Never> { get }
    
    func didFinishReading()
}

final class NewsDetailViewModel: NewsDetailViewModelProtocol {
    
    enum NavigationStep {
        case close
    }
    // MARK: - Private properties

    @Published private var request: URLRequest
    
    private let navigationSubject = PassthroughSubject<NavigationStep, Never>()
    
    // MARK: - Public properties
    
    var navigationStepPublisher: AnyPublisher<NavigationStep, Never> {
        navigationSubject.eraseToAnyPublisher()
    }
    
    var requestPublisher: AnyPublisher<URLRequest, Never> {
        $request.eraseToAnyPublisher()
    }
    
    // MARK: - Init
    
    init(news: News) {
        request = URLRequest(url: news.fullURL)
    }
    
    // MARK: - Public methods
    
    func didFinishReading() {
        navigationSubject.send(.close)
    }
}
