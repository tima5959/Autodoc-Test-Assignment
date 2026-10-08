//
//  NewsFeedViewModel.swift
//  NewsFeed
//
//  Created by Timur  on 06.10.2026.
//

import Foundation
import News

@MainActor
public final class NewsFeedViewModel {

    public enum State {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Public properties

    public var onStateChange: ((State) -> Void)?
    public private(set) var items: [NewsFeedItem] = []

    // MARK: - Private properties

    private var newsFeedService: NewsFeedServiceProtocol

    private var page = 1
    private var pageSize = 15

    private var hasMore: Bool = true
    private var isLoading: Bool = false

    // MARK: - Init

    public init(newsFeedService: NewsFeedServiceProtocol) {
        self.newsFeedService = newsFeedService
    }

    // MARK: - Public methods

    public func refresh() {
        Task {
            await load(isRefreshing: true)
        }
    }

    public func loadNews() {
        Task {
            await load(isRefreshing: false)
        }
    }

    public func loadNextNewsIfNeeded() {
        Task {
            await load(isRefreshing: false)
        }
    }

    // MARK: - Private methods

    private func load(isRefreshing: Bool) async {
        guard !isLoading else { return }
        guard isRefreshing || hasMore else { return }

        isLoading = true
        defer { isLoading = false }

        if isRefreshing {
            page = 1
            hasMore = true
        }

        onStateChange?(.loading)

        do {
            let response = try await newsFeedService.fetchNews(page: page, pageSize: pageSize)

            if isRefreshing {
                items = response.news
            } else {
                let existingNEws = Set(items.map(\.id))
                let filteredNews = response.news.filter { !existingNEws.contains($0.id) }
                items += filteredNews
            }

            hasMore = !response.news.isEmpty && items.count < response.totalCount
            page += 1

            onStateChange?(.loaded)
        } catch {
            onStateChange?(.error(error.localizedDescription))
        }
    }
}

