//
//  NewsViewController.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 18.04.2025.
//

import UIKit
import Combine

final class NewsListViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        return collectionView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Private Properties
    
    private let viewModel: any NewsListViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<Section, NewsCellModel>!
    private var loadingState = LoadingState.idle
    
    // MARK: - Lifecycle
    
    init(viewModel: any NewsListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        setupBindings()
        registerFooter()
        viewModel.loadNewsIfNeeded(item: nil)
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        title = "Новости"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func registerFooter() {
        collectionView.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterView.reuseIdentifier
        )
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(400)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(400)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 32
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 16,
                leading: 0,
                bottom: 16,
                trailing: 0
            )
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(44)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]
            return section
        })
        
        return layout
    }

    
    private func configureDataSource() {
        let imageLoader = viewModel.imageLoader
        let cellRegistration = UICollectionView.CellRegistration<NewsCell, NewsCellModel> {
            cell, _, model in
            cell.configure(with: model, imageLoader: imageLoader)
        }
        
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, model in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: model
            )
        }
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self,
                  kind == UICollectionView.elementKindSectionFooter,
                  let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                    for: indexPath
                  ) as? LoadingFooterView else {
                return nil
            }
            if self.loadingState == .loadingMore {
                footer.startAnimating()
            } else {
                footer.stopAnimating()
            }
            return footer
        }
    }
    
    private func setupBindings() {
        viewModel.newsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] news in
                var snapshot = NSDiffableDataSourceSnapshot<Section, NewsCellModel>()
                snapshot.appendSections([.main])
                // где-то повторяется айдишник, поэтому применяется фильтрация,
                // чтобы не крашилось
                snapshot.appendItems(news.uniqued())
                self?.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
        
        viewModel.loadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.loadingState = state
                switch state {
                case .initial:
                    self.activityIndicator.startAnimating()
                    
                case .idle, .loadingMore:
                    if self.activityIndicator.isAnimating {
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension NewsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.showSelectedItem(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.loadNewsIfNeeded(item: item)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension NewsListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let indices = indexPaths.map { $0.item }
        viewModel.prefetchItems(at: indices)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let indices = indexPaths.map { $0.item }
        viewModel.cancelPrefetching(at: indices)
    }
}
