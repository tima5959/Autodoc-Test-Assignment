//
//  NewsFeedService.swift
//  News
//
//  Created by Timur  on 06.10.2026.
//

import Foundation

public struct NewsFeedService: NewsFeedServiceProtocol {
    private let urlSession: URLSession
    private let baseURL = URL(string: "https://webapi.autodoc.ru/api/news")

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func fetchNews(page: Int, pageSize: Int) async throws -> NewsFeedResponse {
        guard let url = baseURL?.appending(path: "\(page)/\(pageSize)") else { throw URLError(.badURL) }

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(NewsFeedResponse.self, from: data)

        return decoded
    }
}
