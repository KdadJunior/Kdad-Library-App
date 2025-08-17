//
//  DashboardViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/12/25.
//

import UIKit
import AVFoundation

class DashboardViewController: UIViewController {

    // MARK: UI Elements

    private let backgroundView: UIView = {
        let view = UIView()
        // Slightly lighter vanilla color (#F9F7EF)
        view.backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 0.94, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Navigation Bar container (custom)
    private let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .systemIndigo
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityLabel = "Back"
        return btn
    }()

    private let profileButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "person.circle"), for: .normal)
        btn.tintColor = .systemIndigo
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityLabel = "Profile"
        return btn
    }()

    // Title label
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Dashboard"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .systemIndigo
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Video container view (for playing book animation)
    private let videoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()

    // AVPlayer
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    // Go to Books Button (center, slightly lower)
    private let goToBooksButton: UIButton = {
        let btn = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = "Go to Books"
            config.baseBackgroundColor = .systemIndigo
            config.baseForegroundColor = .white
            config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40)
            btn.configuration = config
        } else {
            btn.setTitle("Go to Books", for: .normal)
            btn.backgroundColor = .systemIndigo
            btn.tintColor = .white
            btn.contentEdgeInsets = UIEdgeInsets(top: 14, left: 40, bottom: 14, right: 40)
        }
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // StackView container for two columns of buttons
    private let buttonsGridStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 30
        stack.alignment = .top
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // Left column vertical stack
    private let leftColumnStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // Right column vertical stack
    private let rightColumnStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // Create grid buttons with icon and title on one line (slightly smaller icon)
    private func createGridButton(title: String, systemImageName: String, tintColor: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        let configImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let image = UIImage(systemName: systemImageName, withConfiguration: configImage)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = image
            config.title = title
            config.baseForegroundColor = tintColor
            config.imagePadding = 8
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                return outgoing
            }
            btn.configuration = config
            btn.contentHorizontalAlignment = .leading
        } else {
            btn.setImage(image, for: .normal)
            btn.setTitle(" \(title)", for: .normal)
            btn.tintColor = tintColor
            btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            btn.contentHorizontalAlignment = .leading
            btn.semanticContentAttribute = .forceLeftToRight
        }
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }

    // Updated button titles and icons as requested
    private lazy var favoriteBooksButton = createGridButton(title: "Favorite Books", systemImageName: "star.fill", tintColor: .systemYellow)
    private lazy var readLaterButton = createGridButton(title: "Read Later", systemImageName: "bookmark.fill", tintColor: .systemBlue)
    private lazy var nearestLibraryButton = createGridButton(title: "Find Library", systemImageName: "location.fill", tintColor: .systemGreen)
    private lazy var chatbotButton = createGridButton(title: "Kdad Chatbot", systemImageName: "headphones", tintColor: .systemPurple)
    private lazy var newReleasesButton = createGridButton(title: "New Release", systemImageName: "book.fill", tintColor: .systemOrange)
    private lazy var settingsButton = createGridButton(title: "Settings", systemImageName: "gearshape.fill", tintColor: .systemGray)

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupActions()
        setupVideoPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoContainerView.bounds
    }

    // MARK: Setup Video Player

    private func setupVideoPlayer() {
        guard let path = Bundle.main.path(forResource: "book_animation", ofType:"mp4") else {
            print("book_animation.mp4 not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else { return }

        playerLayer.videoGravity = .resizeAspect

        view.addSubview(videoContainerView)
        view.addSubview(goToBooksButton)

        videoContainerView.layer.addSublayer(playerLayer)

        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        goToBooksButton.translatesAutoresizingMaskIntoConstraints = false

        playerLayer.frame = CGRect(x: 0, y: 0, width: 400, height: 240)

        NSLayoutConstraint.activate([
            videoContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            videoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            videoContainerView.widthAnchor.constraint(equalToConstant: 400),
            videoContainerView.heightAnchor.constraint(equalToConstant: 240),

            goToBooksButton.topAnchor.constraint(equalTo: videoContainerView.bottomAnchor, constant: 60),
            goToBooksButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        // Add notification observer to loop video
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidReachEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
        player?.play()
    }

    @objc private func playerDidReachEnd(notification: Notification) {
        player?.seek(to: .zero)
        player?.play()
    }

    // MARK: UI Setup

    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(navBarView)

        navBarView.addSubview(backButton)
        navBarView.addSubview(profileButton)
        navBarView.addSubview(titleLabel)

        // Note: goToBooksButton and videoContainerView are added in setupVideoPlayer()

        view.addSubview(buttonsGridStackView)

        buttonsGridStackView.addArrangedSubview(leftColumnStackView)
        buttonsGridStackView.addArrangedSubview(rightColumnStackView)

        // Add buttons to columns (3 buttons each)
        leftColumnStackView.addArrangedSubview(favoriteBooksButton)
        leftColumnStackView.addArrangedSubview(readLaterButton)
        leftColumnStackView.addArrangedSubview(nearestLibraryButton)

        rightColumnStackView.addArrangedSubview(chatbotButton)
        rightColumnStackView.addArrangedSubview(newReleasesButton)
        rightColumnStackView.addArrangedSubview(settingsButton)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            navBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarView.heightAnchor.constraint(equalToConstant: 56),

            backButton.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: navBarView.leadingAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),

            profileButton.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor),
            profileButton.trailingAnchor.constraint(equalTo: navBarView.trailingAnchor, constant: -12),
            profileButton.widthAnchor.constraint(equalToConstant: 32),
            profileButton.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.centerYAnchor.constraint(equalTo: navBarView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: navBarView.centerXAnchor),

            buttonsGridStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            buttonsGridStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonsGridStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            buttonsGridStackView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }

    // MARK: Actions Setup

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)
        goToBooksButton.addTarget(self, action: #selector(didTapGoToBooks), for: .touchUpInside)
        favoriteBooksButton.addTarget(self, action: #selector(didTapFavoriteBooks), for: .touchUpInside)
        readLaterButton.addTarget(self, action: #selector(didTapReadLater), for: .touchUpInside)
        nearestLibraryButton.addTarget(self, action: #selector(didTapNearestLibrary), for: .touchUpInside)
        chatbotButton.addTarget(self, action: #selector(didTapChatbot), for: .touchUpInside)
        newReleasesButton.addTarget(self, action: #selector(didTapNewReleases), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)
    }

    // MARK: Button Actions

    @objc private func didTapBack() {
        // Dismiss dashboard to return to Auth screen
        self.dismiss(animated: true)
    }

    @objc private func didTapProfile() {
        let vc = ProfileViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet // looks nice on iPhone & iPad
        present(nav, animated: true)
    }

    @objc private func didTapGoToBooks() {
        print("Go to Books tapped")
        let bookListVC = BookListViewController()
        let navController = UINavigationController(rootViewController: bookListVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }

    @objc private func didTapFavoriteBooks() {
        let favoritesVC = FavoriteBooksViewController()
        let nav = UINavigationController(rootViewController: favoritesVC)
        nav.modalPresentationStyle = .fullScreen   // keep your modal style
        present(nav, animated: true)
    }

    @objc private func didTapReadLater() {
        print("Read Later tapped")
        let vc = ReadLaterViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func didTapNearestLibrary() {
        let vc = NearestLibraryViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    @objc private func didTapChatbot() {
        print("Ask Kdad Chatbot tapped")
        // TODO: Implement ChatbotViewController navigation here
    }

    @objc private func didTapNewReleases() {
        print("New Releases tapped")
        // TODO: Implement NewReleasesViewController navigation here
    }

    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}
