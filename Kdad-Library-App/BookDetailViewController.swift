//
//  BookDetailViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/5/25.
//

import Foundation
import UIKit
import Nuke
import NukeExtensions

class BookDetailViewController: UIViewController {

    private let book: Book
    private var isFavorite: Bool = false
    private var isReadLater: Bool = false

    // MARK: UI Elements
    private let backdropImageView = UIImageView()
    private let favoriteButton = UIButton(type: .system)
    private let readLaterButton = UIButton(type: .system)
    private let topButtonsStack = UIStackView()

    private let posterImageView = UIImageView()
    private let metaContainer = UIStackView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let releaseDateLabel = UILabel()
    private let ratingLabel = UILabel()
    private let previewButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let descriptionLabel = UILabel()

    // MARK: Init
    init(book: Book) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Book Details"

        setupViews()
        layoutViews()
        configureContent()
    }

    // MARK: Setup
    private func setupViews() {
        [backdropImageView,
         posterImageView,
         metaContainer,
         previewButton,
         scrollView,
         contentView,
         descriptionLabel,
         favoriteButton,
         readLaterButton,
         topButtonsStack
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.clipsToBounds = true

        // --- Buttons (top-right) ---
        // Common style for both circle buttons
        func styleTopIconButton(_ button: UIButton, systemName: String) {
            button.setImage(UIImage(systemName: systemName), for: .normal)
            button.tintColor = .white
            button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            button.layer.cornerRadius = 22
            button.clipsToBounds = true
            button.widthAnchor.constraint(equalToConstant: 44).isActive = true
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }

        styleTopIconButton(favoriteButton, systemName: "heart")
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)

        styleTopIconButton(readLaterButton, systemName: "bookmark")
        readLaterButton.addTarget(self, action: #selector(didTapReadLater), for: .touchUpInside)

        topButtonsStack.axis = .horizontal
        topButtonsStack.alignment = .fill
        topButtonsStack.distribution = .fill
        topButtonsStack.spacing = 8
        topButtonsStack.addArrangedSubview(readLaterButton)  // ⬅️ Left
        topButtonsStack.addArrangedSubview(favoriteButton)   // ⬅️ Right, close to Read Later

        posterImageView.layer.cornerRadius = 18
        posterImageView.layer.borderWidth = 2
        posterImageView.layer.borderColor = UIColor.white.cgColor
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill

        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.numberOfLines = 0
        authorLabel.font = .italicSystemFont(ofSize: 16)
        authorLabel.textColor = .darkGray
        releaseDateLabel.font = .systemFont(ofSize: 14)
        ratingLabel.font = .systemFont(ofSize: 14)

        metaContainer.axis = .vertical
        metaContainer.alignment = .leading
        metaContainer.spacing = 8
        metaContainer.addArrangedSubview(titleLabel)
        metaContainer.addArrangedSubview(authorLabel)
        metaContainer.addArrangedSubview(releaseDateLabel)
        metaContainer.addArrangedSubview(ratingLabel)

        previewButton.setTitle("Open Book", for: .normal)
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.backgroundColor = .systemBlue
        previewButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        previewButton.layer.cornerRadius = 10
        previewButton.addTarget(self, action: #selector(didTapPreview), for: .touchUpInside)

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0

        view.addSubview(backdropImageView)
        view.addSubview(topButtonsStack)
        view.addSubview(posterImageView)
        view.addSubview(metaContainer)
        view.addSubview(previewButton)
        view.addSubview(scrollView)

        scrollView.addSubview(contentView)
        contentView.addSubview(descriptionLabel)
    }

    private func layoutViews() {
        NSLayoutConstraint.activate([
            backdropImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 260),

            // Top-right buttons (Read Later on left, Favorite on right) with tight spacing
            topButtonsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            topButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            posterImageView.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: -50),
            posterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            posterImageView.widthAnchor.constraint(equalToConstant: 140),
            posterImageView.heightAnchor.constraint(equalToConstant: 200),

            metaContainer.topAnchor.constraint(equalTo: posterImageView.topAnchor, constant: 50),
            metaContainer.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            metaContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            previewButton.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 24),
            previewButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            previewButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            previewButton.heightAnchor.constraint(equalToConstant: 44),

            scrollView.topAnchor.constraint(equalTo: previewButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func configureContent() {
        titleLabel.text = book.volumeInfo.title
        authorLabel.text = "Author: " + (book.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown Author")
        releaseDateLabel.text = "Released: \(book.volumeInfo.publishedDate ?? "N/A")"
        ratingLabel.text = book.volumeInfo.averageRating != nil ? "Rating: \(book.volumeInfo.averageRating!)" : ""
        descriptionLabel.text = book.volumeInfo.description ?? "No description available."

        if let thumbnailURL = book.volumeInfo.imageLinks?.thumbnail,
           let url = URL(string: thumbnailURL.replacingOccurrences(of: "http://", with: "https://")) {
            NukeExtensions.loadImage(with: url, into: posterImageView)
            NukeExtensions.loadImage(with: url, into: backdropImageView)
        }

        // Initial state for Favorite / Read Later
        let favorites = Book.getBooks(forKey: Book.favoritesKey)
        isFavorite = favorites.contains { $0.id == book.id }
        updateFavoriteIcon()

        let readLaterList = Book.getBooks(forKey: Book.readLaterKey)
        isReadLater = readLaterList.contains { $0.id == book.id }
        updateReadLaterIcon()
    }

    // MARK: - Actions
    @objc private func didTapFavorite() {
        var favorites = Book.getBooks(forKey: Book.favoritesKey)

        if let index = favorites.firstIndex(where: { $0.id == book.id }) {
            favorites.remove(at: index)
            isFavorite = false
        } else {
            favorites.append(book)
            isFavorite = true
        }

        Book.save(favorites, forKey: Book.favoritesKey)
        updateFavoriteIcon()
    }

    @objc private func didTapReadLater() {
        var readLater = Book.getBooks(forKey: Book.readLaterKey)

        if let index = readLater.firstIndex(where: { $0.id == book.id }) {
            readLater.remove(at: index)
            isReadLater = false
        } else {
            readLater.append(book)
            isReadLater = true
        }

        Book.save(readLater, forKey: Book.readLaterKey)
        updateReadLaterIcon()
    }

    private func updateFavoriteIcon() {
        let imageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func updateReadLaterIcon() {
        let imageName = isReadLater ? "bookmark.fill" : "bookmark"
        readLaterButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func didTapPreview() {
        guard let urlString = book.volumeInfo.previewLink,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
