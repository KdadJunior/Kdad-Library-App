//
//  FavoriteBooksViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/15/25.
//

import UIKit

final class FavoriteBooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var favorites: [Book] = [] { didSet { updateEmptyState() } }

    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No favorite books yet."
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16, weight: .medium)
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Favorite Books"

        // Close button (since we present modally)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )

        // Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BookTableViewCell.self, forCellReuseIdentifier: BookTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Always refresh from storage so it reflects changes from BookDetail
        favorites = Book.getBooks(forKey: Book.favoritesKey)
        tableView.reloadData()
    }

    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func updateEmptyState() {
        tableView.backgroundView = favorites.isEmpty ? emptyLabel : nil
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favorites.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: BookTableViewCell.identifier,
            for: indexPath
        ) as! BookTableViewCell
        cell.configure(with: favorites[indexPath.row])
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let book = favorites[indexPath.row]
        let detailVC = BookDetailViewController(book: book)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Swipe to remove from favorites
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, done in
            guard let self = self else { return }
            var stored = Book.getBooks(forKey: Book.favoritesKey)
            let toRemove = self.favorites[indexPath.row]
            if let i = stored.firstIndex(where: { $0.id == toRemove.id }) {
                stored.remove(at: i)
                Book.save(stored, forKey: Book.favoritesKey)
            }
            self.favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
