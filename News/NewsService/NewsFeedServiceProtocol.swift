//
//  NewsFeedServiceProtocol.swift
//  News
//
//  Created by Timur  on 06.10.2026.
//

import Foundation

public protocol NewsFeedServiceProtocol {
    func fetchNews(page: Int, pageSize: Int) async throws -> NewsFeedResponse
}
