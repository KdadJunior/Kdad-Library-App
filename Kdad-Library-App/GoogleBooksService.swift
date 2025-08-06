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

    func fetchBooks(query: String = "fiction", completion: @escaping (Result<[Book], Error>) -> Void) {
        // URL encode the query string
        guard let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(queryEncoded)&maxResults=40&key=\(apiKey)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle error
            if let error = error {
                completion(.failure(error))
                return
            }

            // Ensure data is received
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 404)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(BookFeed.self, from: data)
                completion(.success(decoded.items))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
