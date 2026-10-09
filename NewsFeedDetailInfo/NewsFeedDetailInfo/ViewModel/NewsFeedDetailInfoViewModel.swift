//
//  NewsFeedDetailInfoViewModel.swift
//  NewsFeedDetailInfo
//
//  Created by Timur  on 09.10.2026.
//

import Combine
import Foundation

@MainActor
public final class NewsFeedDetailInfoViewModel {

    public enum State: Equatable {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Public properties

    public let url: URL
    public let title: String

    @Published public private(set) var state: State = .loading

    // MARK: - Init

    public init(url: URL, title: String) {
        self.url = url
        self.title = title
    }

    // MARK: - Public methods

    public func didStartLoading() {
        state = .loading
    }

    public func didFinishLoading() {
        state = .loaded
    }

    public func didFailLoading(with error: Error) {
        state = .error(error.localizedDescription)
    }
}
