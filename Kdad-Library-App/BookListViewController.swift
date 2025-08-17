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
    private var books: [Book] = [] { didSet { updateEmptyState() } }

    // Live search helpers
    private var searchWorkItem: DispatchWorkItem?
    private var lastIssuedQueryID: Int = 0

    // Loading indicator (used only when NOT pull-to-refresh and NOT paginating)
    private let loadingIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Empty state
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No books found"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16, weight: .medium)
        return l
    }()

    // Pull-to-refresh
    private let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: "Refreshing…")
        return rc
    }()

    // Pagination
    private var currentQuery: String = "fiction"
    private let pageSize: Int = 20
    private var nextStartIndex: Int = 0
    private var totalAvailable: Int = .max
    private var isLoadingPage: Bool = false

    // Footer spinner for pagination
    private lazy var footerSpinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        s.hidesWhenStopped = true
        return s
    }()

    // Pool of default queries so refresh gets fresh content
    private let defaultQueries = [
        "fiction","novel","bestsellers","science fiction","fantasy",
        "history","biography","mystery","technology","poetry","romance",
        "self help","business","travel","psychology","philosophy"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search books"

        setupBackButton()
        setupHeader()
        setupTableView()
        setupLoadingIndicator()
        setupRefreshControl()

        // initial load (first page)
        resetAndLoad(query: currentQuery)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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

    @objc private func didTapBack() { dismiss(animated: true) }

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
        title = ""

        titleLabel.text = "Kdad Library"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        searchBar.searchBarStyle = .minimal
        searchBar.setContentHuggingPriority(.defaultLow, for: .horizontal)

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

        // Footer for pagination spinner (hidden by default)
        tableView.tableFooterView = UIView(frame: .zero)

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

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func updateEmptyState() {
        tableView.backgroundView = books.isEmpty ? emptyLabel : nil
    }

    // MARK: Loading control

    private func setTopLoading(_ loading: Bool) {
        // Show the top spinner only when NOT using pull-to-refresh and NOT paginating
        if tableView.refreshControl?.isRefreshing == true || isLoadingPage {
            loadingIndicator.stopAnimating()
        } else {
            loading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        }
    }

    private func beginPageLoading() {
        isLoadingPage = true
        footerSpinner.startAnimating()
        tableView.tableFooterView = footerSpinner
    }

    private func endPageLoading() {
        isLoadingPage = false
        footerSpinner.stopAnimating()
        tableView.tableFooterView = UIView(frame: .zero)
    }

    // MARK: Data (pagination-aware)

    private func resetAndLoad(query: String) {
        // bump query id to invalidate in-flight requests
        lastIssuedQueryID += 1

        currentQuery = query
        nextStartIndex = 0
        totalAvailable = .max
        books = []
        tableView.reloadData()

        loadNextPage(resetTopSpinner: true)
    }

    private func loadNextPage(resetTopSpinner: Bool = false) {
        guard !isLoadingPage, books.count < totalAvailable else { return }

        let thisQueryID = lastIssuedQueryID
        if resetTopSpinner { setTopLoading(true) } else { beginPageLoading() }

        GoogleBooksService.shared.fetchBooksPage(
            query: currentQuery,
            startIndex: nextStartIndex,
            maxResults: pageSize
        ) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard thisQueryID == self.lastIssuedQueryID else {
                    // stale response from an old query; ignore and stop spinners
                    self.setTopLoading(false)
                    self.endPageLoading()
                    self.refreshControl.endRefreshing()
                    return
                }

                self.setTopLoading(false)
                self.endPageLoading()
                self.refreshControl.endRefreshing()

                switch result {
                case .success(let payload):
                    self.totalAvailable = payload.total
                    let newItems = payload.items
                    self.books.append(contentsOf: newItems)
                    self.nextStartIndex += newItems.count
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Pagination fetch failed:", error)
                }
            }
        }
    }

    // MARK: Pull-to-refresh

    @objc private func handleRefresh() {
        let trimmed = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            let randomQuery = defaultQueries.randomElement() ?? "fiction"
            resetAndLoad(query: randomQuery)
        } else {
            resetAndLoad(query: trimmed)
        }
    }

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { books.count }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BookTableViewCell.identifier,
            for: indexPath
        ) as! BookTableViewCell
        cell.configure(with: books[indexPath.row])
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = BookDetailViewController(book: books[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Trigger next page when approaching the end
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        let threshold = books.count - 5
        if indexPath.row == threshold {
            loadNextPage()
        }
    }

    // MARK: UISearchBarDelegate

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: false)
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.setShowsCancelButton(false, animated: false)

        searchWorkItem?.cancel()
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if trimmed.isEmpty {
                self.resetAndLoad(query: "fiction")
            } else {
                self.resetAndLoad(query: trimmed)
            }
        }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let trimmed = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        resetAndLoad(query: trimmed.isEmpty ? "fiction" : trimmed)
        dismissKeyboard()
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: false)
        return true
    }
}
