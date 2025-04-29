//
//  LoadingFooterView.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 24.04.2025.
//

import UIKit

final class LoadingFooterView: UICollectionReusableView {
    
    static let reuseIdentifier = String(describing: LoadingFooterView.self)
    
    private let indicatorView = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorView)
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        indicatorView.startAnimating()
    }
    
    func stopAnimating()  {
        indicatorView.stopAnimating()
    }
}
