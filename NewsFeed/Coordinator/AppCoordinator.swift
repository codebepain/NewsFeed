//
//  AppCoordinator.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import UIKit

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let container: DependencyContainer
    
    init(
        navigationController: UINavigationController,
        container: DependencyContainer
    ) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        showNewsFeed()
    }
    
    private func showNewsFeed() {
        let newsCoordinator = NewsListCoordinator(
            navigationController: navigationController,
            container: container
        )
        addChildCoordinator(newsCoordinator)
        newsCoordinator.start()
    }
}
