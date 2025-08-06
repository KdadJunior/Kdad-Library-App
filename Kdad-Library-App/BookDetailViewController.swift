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

    // MARK: UI Elements
    private let backdropImageView = UIImageView()
    private let favoriteButton = UIButton(type: .system)
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
        [backdropImageView, favoriteButton, posterImageView,
         metaContainer, previewButton,
         scrollView, contentView, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.clipsToBounds = true

        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .white
        favoriteButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        favoriteButton.layer.cornerRadius = 22
        favoriteButton.clipsToBounds = true
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)

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
        view.addSubview(favoriteButton)
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

            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),

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

        isFavorite = Book.getBooks(forKey: Book.favoritesKey).contains { $0.id == book.id }
        updateFavoriteIcon()
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

    private func updateFavoriteIcon() {
        let image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favoriteButton.setImage(image, for: .normal)
    }

    @objc private func didTapPreview() {
        guard let urlString = book.volumeInfo.previewLink,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
