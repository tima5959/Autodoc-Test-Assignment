//
//  NewsFeedView.swift
//  NewsFeed
//
//  Created by Timur  on 06.10.2026.
//

import UIKit

final public class NewsFeedView: UIView {

    // MARK: - Public properties

    // MARK: - Private properties

    private lazy var newsCollectionViewLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NewsFeedViewInsets.newsCollectionViewItemSize

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NewsFeedViewInsets.newsCollectionViewContentInsets
        section.interGroupSpacing = NewsFeedViewInsets.newsCollectionViewInterGroupSpacing

        return UICollectionViewCompositionalLayout(section: section)
    }()

    // MARK: - UI Components

    public private(set) lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()

        refreshControl.tintColor = .tertiarySystemBackground

        return refreshControl
    }()

    public private(set) lazy var newsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: newsCollectionViewLayout)

        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.refreshControl = refreshControl

        return collectionView
    }()

    // MARK: - Public Methods

    public override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        addSubview(newsCollectionView)

        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            newsCollectionView.topAnchor.constraint(equalTo: topAnchor),
            newsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            newsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            newsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension NewsFeedView {
    enum NewsFeedViewInsets {
        static let newsCollectionViewMinimumLineSpacing: CGFloat = 28
        static let newsCollectionViewMinimumInteritemSpacing: CGFloat = 20
        static let newsCollectionViewInterGroupSpacing: CGFloat = 16
        static let newsCollectionViewItemSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(450)
        )
        static let newsCollectionViewContentInsets: NSDirectionalEdgeInsets = .init(
            top: 16, leading: 0, bottom: 16, trailing: 0
        )
    }
}
