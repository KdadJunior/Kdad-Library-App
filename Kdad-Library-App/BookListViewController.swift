//
//  BookListViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/5/25.
//

import Foundation
import UIKit

class BookListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.setTitle(" Back", for: .normal)
        btn.tintColor = .systemIndigo
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var books: [Book] = [] {
        didSet { updateEmptyState() }
    }

    // MARK: Live search helpers
    private var searchWorkItem: DispatchWorkItem?
    private var lastIssuedQueryID: Int = 0

    // Simple loading indicator centered above the list
    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Empty state label
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No books found"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16, weight: .medium)
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        searchBar.delegate = self
        searchBar.showsCancelButton = false   // never show Cancel
        searchBar.placeholder = "Search books"

        setupBackButton()
        setupHeader()
        setupTableView()
        setupLoadingIndicator()
        fetchBooks() // initial load with default query ("fiction")

        // Tap anywhere to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func setupBackButton() {
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }

    @objc private func didTapBack() {
        dismiss(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }

    private func setupHeader() {
        title = ""  // Remove default nav title

        // Title
        titleLabel.text = "Kdad Library"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        // SearchBar
        searchBar.searchBarStyle = .minimal
        searchBar.setContentHuggingPriority(.defaultLow, for: .horizontal)
        searchBar.showsCancelButton = false

        // Stack
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(searchBar)

        view.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
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
        tableView.keyboardDismissMode = .onDrag

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 12)
        ])
    }

    private func updateEmptyState() {
        tableView.backgroundView = books.isEmpty ? emptyLabel : nil
    }

    // MARK: Data

    private func setLoading(_ loading: Bool) {
        if loading { loadingIndicator.startAnimating() }
        else { loadingIndicator.stopAnimating() }
    }

    /// Default fetch used on first load or when search text is cleared.
    private func fetchBooks() {
        setLoading(true)
        GoogleBooksService.shared.fetchBooks { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setLoading(false)
                switch result {
                case .success(let books):
                    self.books = books
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch books:", error)
                    self.books = []
                    self.tableView.reloadData()
                }
            }
        }
    }

    /// Debounced search against Google Books.
    private func searchBooks(query: String) {
        setLoading(true)
        let queryID = lastIssuedQueryID + 1
        lastIssuedQueryID = queryID

        GoogleBooksService.shared.fetchBooks(query: query) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // Ignore stale responses
                guard queryID == self.lastIssuedQueryID else { return }
                self.setLoading(false)
                switch result {
                case .success(let books):
                    self.books = books
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Search failed:", error)
                    self.books = []
                    self.tableView.reloadData()
                }
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

    // MARK: - UISearchBarDelegate

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: false)
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.setShowsCancelButton(false, animated: false)

        // Debounce: cancel any pending work
        searchWorkItem?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // If cleared, restore default list after a short delay
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if trimmed.isEmpty {
                self.fetchBooks()
            } else {
                self.searchBooks(query: trimmed)
            }
        }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Perform immediate search when user taps Search on keyboard
        let trimmed = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            fetchBooks()
        } else {
            searchBooks(query: trimmed)
        }
        dismissKeyboard()
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: false)
        return true
    }
}
