//
//  NewsListCoordinator.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import UIKit
import Combine

protocol NewsListCoordinatorProtocol: Coordinator {
    func handle(_ navigationStep: NewsListViewModel.NavigationStep)
}

final class NewsListCoordinator: NewsListCoordinatorProtocol {
    let navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let container: DependencyContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController, container: DependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let viewModel = container.resolve((any NewsListViewModelProtocol).self)
        bindNavigation(for: viewModel)
        
        let newsVC = NewsListViewController(viewModel: viewModel)
        navigationController.pushViewController(newsVC, animated: false)
    }
    
    private func bindNavigation(for viewModel: any NewsListViewModelProtocol) {
        viewModel.navigationStepPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] step in
                self?.handle(step)
            }
            .store(in: &cancellables)
    }
    
    func handle(_ navigationStep: NewsListViewModel.NavigationStep) {
        switch navigationStep {
        case .showNewsDetail(let news):
            let detailCoordinator = NewsDetailCoordinator(
                navigationController: navigationController,
                container: container,
                news: news
            )
            addChildCoordinator(detailCoordinator)
            detailCoordinator.start()
        }
    }
}
