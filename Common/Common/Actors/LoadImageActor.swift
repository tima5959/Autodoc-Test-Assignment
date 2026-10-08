//
//  LoadImageActor.swift
//  Common
//
//  Created by Timur  on 08.10.2026.
//

import UIKit

public actor LoadImageActor {
    public static let shared = LoadImageActor()

    private let cache = NSCache<NSURL, UIImage>()
    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        cache.countLimit = 200
    }

    public func loadImage(from url: URL) async throws -> UIImage {
        if let cache = cache.object(forKey: url as NSURL) {
            return await cache.byPreparingForDisplay() ?? cache
        }

        // Можно покрыть еще ошибки в респонсе и возвращать дефолтную картинку
        let (data, response) = try await URLSession.shared.data(from: url)

        guard
            let httpResponse = response as? HTTPURLResponse,
            (200..<300).contains(httpResponse.statusCode),
            let image = UIImage(data: data)
        else {
            throw URLError(.cannotDecodeContentData)
        }

        // byPreparingForDisplay использую для оптимизации UI при установке картинки
        // из документации понял, что метод вернет картинку асинхронно, когда система будет свободна,
        // что исключает подлагивания листа (в теории)
        let prepared = await image.byPreparingForDisplay() ?? image
        cache.setObject(prepared, forKey: url as NSURL)

        return prepared
    }
}
