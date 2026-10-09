//
//  NewsFeedItem.swift
//  News
//
//  Created by Timur  on 06.10.2026.
//

import Foundation

public struct NewsFeedItem: Decodable, Hashable {
    public let id: Int
    public let title: String
    public let description: String?
    public let publishedDate: String
    public let url: String?
    public let fullUrl: String?
    public let titleImageUrl: String?
    public let categoryType: CategoryType

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case publishedDate
        case url
        case fullUrl
        case titleImageUrl
        case categoryType
    }
}

public enum CategoryType: String, Decodable {
    case autoNews = "Автомобильные новости"
    case companyNews = "Новости компании"
    case unknown

    public init(from decoder: any Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = CategoryType(rawValue: value) ?? .unknown
    }

    public var title: String {
        switch self {
        case .autoNews:
            return "Автомобильные новости"
        case .companyNews:
            return "Новости компании"
        case .unknown:
            return "Новость"
        }
    }
}
