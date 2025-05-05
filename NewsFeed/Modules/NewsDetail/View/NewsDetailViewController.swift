//
//  NewsDetailViewController.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import Combine
import UIKit
import WebKit

final class NewsDetailViewController: UIViewController {
    private let webView = WKWebView()
    private let viewModel: any NewsDetailViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: any NewsDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.allowsBackForwardNavigationGestures = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapDone)
        )
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.requestPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] request in
                self?.webView.load(request)
            }
            .store(in: &cancellables)
    }
    
    @objc private func didTapDone() {
        viewModel.didFinishReading()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension NewsDetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !webView.canGoBack {
            viewModel.didFinishReading()
        }
        return true
    }
}
