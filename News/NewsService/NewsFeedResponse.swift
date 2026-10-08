//
//  NewsFeedResponse.swift
//  News
//
//  Created by Timur  on 06.10.2026.
//

import Foundation

public struct NewsFeedResponse: Decodable {
    public let news: [NewsFeedItem]
    public let totalCount: Int
}
