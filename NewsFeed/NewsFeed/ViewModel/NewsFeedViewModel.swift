//
//  NewsFeedViewModel.swift
//  NewsFeed
//
//  Created by Timur  on 06.10.2026.
//

import Combine
import Foundation
import News

@MainActor
public final class NewsFeedViewModel {

    public enum State: Equatable {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Public properties

    @Published public private(set) var state: State = .loading
    @Published public private(set) var items: [NewsFeedItem] = []

    // MARK: - Private properties

    private let newsFeedService: NewsFeedServiceProtocol
    private let pageSize = 15

    private var page = 1
    private var hasMore = true
    private var loadTask: Task<Void, Never>?

    // MARK: - Init

    public init(newsFeedService: NewsFeedServiceProtocol) {
        self.newsFeedService = newsFeedService
    }

    // MARK: - Public methods

    public func refresh() {
        loadTask?.cancel()
        loadTask = Task { await load(isRefreshing: true) }
    }

    public func loadNews() {
        guard loadTask == nil else { return }
        loadTask = Task { await load(isRefreshing: false) }
    }

    public func loadNextNewsIfNeeded() {
        loadNews()
    }

    // MARK: - Private methods

    private func load(isRefreshing: Bool) async {
        guard isRefreshing || hasMore else {
            loadTask = nil
            return
        }

        if isRefreshing {
            page = 1
            hasMore = true
        }

        state = .loading

        do {
            let response = try await newsFeedService.fetchNews(page: page, pageSize: pageSize)
            guard !Task.isCancelled else { return }

            if isRefreshing {
                items = response.news
            } else {
                let existingNEws = Set(items.map(\.id))
                items += response.news.filter { !existingNEws.contains($0.id) }
            }

            hasMore = !response.news.isEmpty && items.count < response.totalCount
            page += 1
            state = .loaded
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }

        loadTask = nil
    }
}
