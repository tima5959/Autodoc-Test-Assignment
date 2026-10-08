//
//  NewsFeedViewController.swift
//  NewsFeed
//
//  Created by Timur  on 06.10.2026.
//

import UIKit
import News

final public class NewsFeedViewController: UIViewController {

    // MARK: - Public properties

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

    // MARK: - UI Components

    // MARK: - Public Methods

    public init(viewModel: NewsFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func loadView() {
        view = baseView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        baseView.newsCollectionView.delegate = self
        baseView.newsCollectionView.dataSource = dataSource
        baseView.newsCollectionView.register(
            NewsFeedCell.self,
            forCellWithReuseIdentifier: NewsFeedCell.reuseIdentifier
        )
        baseView.newsCollectionView.refreshControl?
            .addTarget(self, action: #selector(refresh), for: .valueChanged)

        configureState()

        viewModel.loadNews()
    }

    // MARK: - Private methods

    private func configureState() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state {
            case .loaded:
                if self.baseView.refreshControl.isRefreshing {
                    self.baseView.refreshControl.endRefreshing()
                }
                self.applySnapshot()
            case .loading:
                break
            case .error(let error):
                // TODO: Придумать что делать в таком случае. За время теста не замечено ни одного случая
                print("In \(#file) \(#function) get error: ", error)
                if self.baseView.refreshControl.isRefreshing {
                    self.baseView.refreshControl.endRefreshing()
                }
            }
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, NewsFeedItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    @objc private func refresh() {
        baseView.refreshControl.beginRefreshing()
        viewModel.refresh()
    }
}

extension NewsFeedViewController: UICollectionViewDelegate {
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
