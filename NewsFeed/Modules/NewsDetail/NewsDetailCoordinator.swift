//
//  NewsDetailCoordinator.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import UIKit
import Combine

protocol NewsDetailCoordinatorProtocol: Coordinator {
    func handle(_ step: NewsDetailViewModel.NavigationStep)
}

final class NewsDetailCoordinator: NewsDetailCoordinatorProtocol {
    let navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let container: DependencyContainer
    private let news: News
    
    init(
        navigationController: UINavigationController,
        container: DependencyContainer,
        news: News
    ) {
        self.navigationController = navigationController
        self.container = container
        self.news = news
    }
    
    func start() {
        let viewModel = container.resolve((any NewsDetailViewModelProtocol).self, argument: news)
        let vc = NewsDetailViewController(viewModel: viewModel)
        bindNavigation(for: viewModel)

        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        navigationController.interactivePopGestureRecognizer?.delegate = vc
        navigationController.pushViewController(vc, animated: true)
    }
    
    func handle(_ step: NewsDetailViewModel.NavigationStep) {
        switch step {
        case .close:
            navigationController.popViewController(animated: true)
        }
    }
    
    private func bindNavigation(for viewModel: any NewsDetailViewModelProtocol) {
        viewModel.navigationStepPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] step in
                self?.handle(step)
            }
            .store(in: &cancellables)
    }
}
