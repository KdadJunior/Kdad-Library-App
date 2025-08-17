//
//  ProfileViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/16/25.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileViewController: UIViewController {

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.15)
        v.layer.cornerRadius = 48
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let initialsLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textColor = .systemIndigo
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.numberOfLines = 2
        return l
    }()

    // Updated: use UIButton.Configuration on iOS 15+ (no deprecation warnings)
    private let verifyBadge: UIButton = {
        let b = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.title = "Email not verified • Tap to resend"
            config.baseForegroundColor = .systemOrange
            config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
            // background with rounded corners
            var bg = UIBackgroundConfiguration.listCell()
            bg.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
            bg.cornerRadius = 8
            config.background = bg
            b.configuration = config
        } else {
            b.setTitle("Email not verified • Tap to resend", for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
            b.tintColor = .systemOrange
            b.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
            b.layer.cornerRadius = 8
            b.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        }
        b.isHidden = true
        return b
    }()

    private lazy var editNameButton: UIButton = makePrimaryButton(title: "Edit Display Name", systemImage: "pencil")
    private lazy var changePasswordButton: UIButton = makePrimaryButton(title: "Change Password (Email Link)", systemImage: "key.fill")
    private lazy var refreshButton: UIButton = makeSecondaryButton(title: "Refresh", systemImage: "arrow.clockwise")

    private let activity = UIActivityIndicatorView(style: .medium)

    // MARK: - Data

    private let db = Firestore.firestore()
    private var user: User? { Auth.auth().currentUser }
    private var userDoc: [String: Any]? // Firestore "users/{uid}"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf)
        )

        setupLayout()
        wireActions()
        renderSkeleton()
        loadProfile()
    }

    // MARK: - Layout

    private func setupLayout() {
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.axis = .vertical
        contentView.alignment = .fill
        contentView.spacing = 16
        contentView.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        // Avatar
        avatarView.addSubview(initialsLabel)
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 96),
            avatarView.heightAnchor.constraint(equalToConstant: 96),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
        ])

        let headerStack = UIStackView(arrangedSubviews: [avatarView, nameLabel, emailLabel, verifyBadge])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 10

        let buttonsStack = UIStackView(arrangedSubviews: [editNameButton, changePasswordButton, refreshButton])
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 12

        contentView.addArrangedSubview(headerStack)
        contentView.addArrangedSubview(buttonsStack)

        // Activity
        activity.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activity)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])

        // Buttons height
        [editNameButton, changePasswordButton, refreshButton].forEach {
            $0.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
    }

    private func makePrimaryButton(title: String, systemImage: String) -> UIButton {
        let b = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.image = UIImage(systemName: systemImage)
            config.imagePadding = 8
            config.baseBackgroundColor = .systemIndigo
            config.baseForegroundColor = .white
            b.configuration = config
        } else {
            b.setTitle(title, for: .normal)
            b.setImage(UIImage(systemName: systemImage), for: .normal)
            b.tintColor = .white
            b.backgroundColor = .systemIndigo
            b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }
        b.layer.cornerRadius = 12
        b.clipsToBounds = true
        return b
    }

    private func makeSecondaryButton(title: String, systemImage: String) -> UIButton {
        let b = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.gray()
            config.title = title
            config.image = UIImage(systemName: systemImage)
            config.imagePadding = 8
            b.configuration = config
        } else {
            b.setTitle(title, for: .normal)
            b.tintColor = .label
            b.backgroundColor = UIColor.secondarySystemBackground
            b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        }
        b.layer.cornerRadius = 12
        b.clipsToBounds = true
        return b
    }

    // MARK: - Actions

    private func wireActions() {
        editNameButton.addTarget(self, action: #selector(didTapEditName), for: .touchUpInside)
        changePasswordButton.addTarget(self, action: #selector(didTapChangePassword), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(didTapRefresh), for: .touchUpInside)
        verifyBadge.addTarget(self, action: #selector(didTapResendVerification), for: .touchUpInside)
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    @objc private func didTapRefresh() {
        loadProfile()
    }

    @objc private func didTapEditName() {
        let current = (userDoc?["name"] as? String) ?? nameLabel.text ?? ""
        let alert = UIAlertController(title: "Edit Display Name", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Your name"
            tf.text = current
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self, let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty, let uid = self.user?.uid else { return }
            self.setLoading(true)
            self.db.collection("users").document(uid).setData(["name": newName], merge: true) { err in
                self.setLoading(false)
                if let err = err {
                    self.presentError("Couldn't save name", err.localizedDescription)
                } else {
                    self.userDoc?["name"] = newName
                    self.render()
                }
            }
        }))
        present(alert, animated: true)
    }

    @objc private func didTapChangePassword() {
        guard let email = user?.email else {
            presentError("No Email", "We couldn't find your email address.")
            return
        }
        setLoading(true)
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            self?.setLoading(false)
            if let error = error {
                self?.presentError("Couldn't Send Reset", error.localizedDescription)
            } else {
                self?.presentInfo("Password Reset Sent", "Check \(email) for a reset link.")
            }
        }
    }

    @objc private func didTapResendVerification() {
        guard let u = user, !u.isEmailVerified else { return }
        setLoading(true)
        u.sendEmailVerification { [weak self] error in
            self?.setLoading(false)
            if let error = error {
                self?.presentError("Couldn't Send Email", error.localizedDescription)
            } else {
                self?.presentInfo("Verification Sent", "Check your inbox to verify your email.")
            }
        }
    }

    // MARK: - Data

    private func loadProfile() {
        guard let uid = user?.uid else {
            renderSignedOut()
            return
        }
        setLoading(true)
        db.collection("users").document(uid).getDocument { [weak self] snap, err in
            guard let self = self else { return }
            self.setLoading(false)
            if let err = err {
                self.presentError("Couldn't Load Profile", err.localizedDescription)
                self.userDoc = nil
            } else {
                self.userDoc = snap?.data()
            }
            self.render()
        }
        user?.reload(completion: { [weak self] _ in
            self?.render()
        })
    }

    // MARK: - Rendering

    private func renderSkeleton() {
        nameLabel.text = "—"
        emailLabel.text = "—"
        initialsLabel.text = "?"
    }

    private func renderSignedOut() {
        nameLabel.text = "Not signed in"
        emailLabel.text = ""
        initialsLabel.text = "?"
        verifyBadge.isHidden = true
        editNameButton.isEnabled = false
        changePasswordButton.isEnabled = false
        refreshButton.isEnabled = false
    }

    private func render() {
        guard let u = user else { renderSignedOut(); return }

        let name = (userDoc?["name"] as? String) ?? "Your Name"
        let email = u.email ?? "—"

        nameLabel.text = name
        emailLabel.text = email
        initialsLabel.text = initials(from: name)

        verifyBadge.isHidden = u.isEmailVerified
    }

    private func initials(from name: String) -> String {
        let parts = name
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        return parts.joined().isEmpty ? "U" : parts.joined()
    }

    // MARK: - Helpers

    private func setLoading(_ loading: Bool) {
        loading ? activity.startAnimating() : activity.stopAnimating()
        view.isUserInteractionEnabled = !loading
    }

    private func presentError(_ title: String, _ message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    private func presentInfo(_ title: String, _ message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
