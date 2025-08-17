//
//  GoogleBooksService.swift
//  Kdad-Library-App
//
//  Created by user on 8/5/25.
//

import Foundation

class GoogleBooksService {
    static let shared = GoogleBooksService()
    private init() {}

    private let apiKey = "AIzaSyCDcoX1CoJEmstwHF8EUsq4xa9nLu_-Mv4"

    // Existing simple fetch (kept for compatibility)
    func fetchBooks(query: String = "fiction", completion: @escaping (Result<[Book], Error>) -> Void) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(queryEncoded)&maxResults=40&key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404)))
                return
            }

            do {
                // This works with your current BookFeed model
                let decoded = try JSONDecoder().decode(BookFeed.self, from: data)
                completion(.success(decoded.items))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // NEW: Paginated fetch that also returns total count
    struct PageResult: Decodable {
        let totalItems: Int
        let items: [Book]?
    }

    func fetchBooksPage(
        query: String,
        startIndex: Int,
        maxResults: Int,
        completion: @escaping (Result<(items: [Book], total: Int), Error>) -> Void
    ) {
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string:
                "https://www.googleapis.com/books/v1/volumes?q=\(queryEncoded)&startIndex=\(startIndex)&maxResults=\(maxResults)&key=\(apiKey)"
              ) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(PageResult.self, from: data)
                completion(.success((decoded.items ?? [], decoded.totalItems)))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
