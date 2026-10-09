//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Timur  on 06.10.2026.
//

import Combine
import UIKit
import News
import SafariServices

final public class NewsFeedViewController: UIViewController {

    // MARK: - Public properties

    public var onSelecteNews: ((URL, String) -> Void)?

    // MARK: - Private properties

    private let viewModel: NewsFeedViewModel

    private lazy var baseView = NewsFeedView()

    private lazy var dataSource = UICollectionViewDiffableDataSource<Int, NewsFeedItem>(
        collectionView: baseView.newsCollectionView
    ) { (collectionView: UICollectionView, indexPath: IndexPath, item: NewsFeedItem) -> UICollectionViewCell? in
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NewsFeedCell.reuseIdentifier,
            for: indexPath
        ) as? NewsFeedCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: item)

        return cell
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    // MARK: - Public Methods

    public init(viewModel: NewsFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    public override func loadView() {
        view = baseView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Autodoc Test Assignment"

        baseView.newsCollectionView.delegate = self
        baseView.newsCollectionView.dataSource = dataSource
        baseView.newsCollectionView.register(
            NewsFeedCell.self,
            forCellWithReuseIdentifier: NewsFeedCell.reuseIdentifier
        )
        baseView.newsCollectionView.refreshControl?
            .addTarget(self, action: #selector(refresh), for: .valueChanged)

        bind()

        viewModel.loadNews()
    }

    // MARK: - Private methods

    private func bind() {
        let cancellablesArray = [
            viewModel.$items
                .sink { [weak self] items in
                    guard let self else { return }

                    self.applySnapshot(with: items)
                },

            viewModel.$state
                .removeDuplicates()
                .sink { [weak self] state in
                    guard let self else { return }

                    self.configureUI(state)
                }
        ]

        cancellables.formUnion(cancellablesArray)
    }

    private func configureUI(_ state: NewsFeedViewModel.State) {
        switch state {
        case .loaded:
            self.endRefreshIfNeeded()
        case .loading:
            // TODO: Добавить UIActivityIndicator или скелетон
            break
        case .error(let error):
            // TODO: Придумать что делать в таком случае. За время теста не замечено ни одного случая
            print("In \(#file) \(#function) get error: ", error)
            self.endRefreshIfNeeded()
        }
    }

    private func applySnapshot(with items: [NewsFeedItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, NewsFeedItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func endRefreshIfNeeded() {
        if self.baseView.refreshControl.isRefreshing {
            self.baseView.refreshControl.endRefreshing()
        }
    }

    @objc private func refresh() {
        viewModel.refresh()
    }
}

extension NewsFeedViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        guard
            let item = dataSource.itemIdentifier(for: indexPath),
            let urlString = item.fullUrl,
            let url = URL(string: urlString)
        else { return }

        onSelecteNews?(url, item.title)
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.item >= viewModel.items.count - 5 {
            viewModel.loadNextNewsIfNeeded()
        }
    }
}
