//
//  Book.swift
//  Kdad-Library-App
//
//  Created by user on 8/5/25.
//

import Foundation

// Top-level response from Google Books API
struct BookFeed: Decodable {
    let items: [Book]
}

// The main book model
struct Book: Codable {
    let id: String
    let volumeInfo: VolumeInfo

    struct VolumeInfo: Codable {
        let title: String
        let authors: [String]?
        let publishedDate: String?
        let description: String?
        let imageLinks: ImageLinks?
        let averageRating: Double?
        let previewLink: String?
    }

    struct ImageLinks: Codable {
        let thumbnail: String?
        let smallThumbnail: String?
    }
}

// MARK: - Favorite Storage Helper
extension Book {
    static var favoritesKey: String {
        return "FavoriteBooks"
    }

    static func save(_ books: [Book], forKey key: String) {
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(books) {
            defaults.set(encoded, forKey: key)
        }
    }

    static func getBooks(forKey key: String) -> [Book] {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Book].self, from: data) {
            return decoded
        }
        return []
    }
}
