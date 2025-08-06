//
//  BookListViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/5/25.
//

import Foundation
import UIKit

class BookListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var books: [Book] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        searchBar.delegate = self      // 🔹 Required for resigning first responder
        setupHeader()
        setupTableView()
        fetchBooks()

        // 🔹 Tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupHeader() {
        title = ""  // Remove the default nav title

        // Configure title
        titleLabel.text = "Kdad Library"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        // Configure search bar
        searchBar.placeholder = "Search books"
        searchBar.searchBarStyle = .minimal
        searchBar.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // Stack setup
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(searchBar)

        view.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func fetchBooks() {
        GoogleBooksService.shared.fetchBooks { [weak self] result in
            switch result {
            case .success(let books):
                self?.books = books
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch books:", error)
            }
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BookTableViewCell.identifier,
            for: indexPath
        ) as! BookTableViewCell

        let book = books[indexPath.row]
        cell.configure(with: book)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let book = books[indexPath.row]
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
