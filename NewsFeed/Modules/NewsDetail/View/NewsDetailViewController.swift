//
//  NewsDetailViewController.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import UIKit
import SafariServices
import Combine

final class NewsDetailViewController: UIViewController {
    private let viewModel: any NewsDetailViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: any NewsDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.newsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] news in
                let safariVC = SFSafariViewController(url: news.fullURL)
                safariVC.delegate = self
                self?.present(safariVC, animated: true)
            }
            .store(in: &cancellables)
    }
}

extension NewsDetailViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        viewModel.didFinishReading()
    }
}
