//
//  SettingsViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/18/25.
//

import UIKit
import FirebaseAuth

/// Persisted theme choice
private enum ThemePreference: Int {
    case system = 0, light = 1, dark = 2

    static let storageKey = "ThemePreference"

    static var current: ThemePreference {
        let raw = UserDefaults.standard.integer(forKey: storageKey)
        return ThemePreference(rawValue: raw) ?? .system
    }

    static func apply(_ pref: ThemePreference) {
        UserDefaults.standard.set(pref.rawValue, forKey: storageKey)

        let style: UIUserInterfaceStyle
        switch pref {
        case .system: style = .unspecified
        case .light:  style = .light
        case .dark:   style = .dark
        }

        // Apply to the whole app
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}

final class SettingsViewController: UIViewController {

    // MARK: UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // MARK: Firebase listener handle (fixes the warning)
    private var authHandle: AuthStateDidChangeListenerHandle?

    // MARK: Data model
    private enum Section: Int, CaseIterable {
        case account
        case appearance
        case about
    }

    // Rows by section
    private enum AccountRow: Int, CaseIterable {
        case email
        case verifyEmailIfNeeded
        case signOut
    }
    private enum AppearanceRow: Int, CaseIterable {
        case theme
    }
    private enum AboutRow: Int, CaseIterable {
        case version
    }

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf)
        )

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Keep UI in sync if user state changes elsewhere
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            self?.tableView.reloadData()
        }
    }

    deinit {
        // Clean up state change listener
        if let h = authHandle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }

    // MARK: Actions
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }

    private func signOut() {
        let confirm = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .actionSheet
        )
        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            do {
                try Auth.auth().signOut()
                // Reset app root to Auth screen
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let delegate = scene.delegate as? SceneDelegate,
                   let window = delegate.window {
                    let nav = UINavigationController(rootViewController: AuthViewController())
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                } else {
                    self.dismiss(animated: true)
                }
            } catch {
                self.showAlert(title: "Sign Out Failed", message: error.localizedDescription)
            }
        })
        present(confirm, animated: true)
    }

    private func resendVerificationEmail() {
        guard let user = Auth.auth().currentUser, !user.isEmailVerified else {
            showAlert(title: "Already Verified", message: "Your email is already verified.")
            return
        }
        user.sendEmailVerification { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Couldn't Send Email", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Verification Sent", message: "Check your inbox to verify your email.")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .account:
            // We still return 3; row 1 will hide itself if not needed
            return AccountRow.allCases.count
        case .appearance:
            return AppearanceRow.allCases.count
        case .about:
            return AboutRow.allCases.count
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sec = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .default
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

        switch sec {
        case .account:
            let row = AccountRow(rawValue: indexPath.row)!
            switch row {
            case .email:
                cell.selectionStyle = .none
                let email = Auth.auth().currentUser?.email ?? "Not signed in"
                cell.textLabel?.text = "Signed in as\n\(email)"
                cell.textLabel?.font = .systemFont(ofSize: 15)
                cell.textLabel?.textColor = .secondaryLabel

            case .verifyEmailIfNeeded:
                if let user = Auth.auth().currentUser, !user.isEmailVerified {
                    cell.textLabel?.text = "Resend Verification Email"
                    cell.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
                    cell.accessoryType = .disclosureIndicator
                } else {
                    // Hide/unusable row when already verified
                    cell.textLabel?.text = "Email Verified"
                    cell.selectionStyle = .none
                    cell.textLabel?.textColor = .secondaryLabel
                }

            case .signOut:
                cell.textLabel?.text = "Sign Out"
                cell.textLabel?.textColor = .systemRed
                cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            }

        case .appearance:
            let row = AppearanceRow(rawValue: indexPath.row)!
            switch row {
            case .theme:
                cell.selectionStyle = .none
                cell.textLabel?.text = "Appearance"

                let seg = UISegmentedControl(items: ["System", "Light", "Dark"])
                seg.selectedSegmentIndex = ThemePreference.current.rawValue
                seg.addTarget(self, action: #selector(themeChanged(_:)), for: .valueChanged)
                cell.accessoryView = seg
            }

        case .about:
            let row = AboutRow(rawValue: indexPath.row)!
            switch row {
            case .version:
                cell.selectionStyle = .none
                let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                cell.textLabel?.text = "Version \(v) (\(b))"
                cell.textLabel?.textColor = .secondaryLabel
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .account:    return "Account"
        case .appearance: return "Appearance"
        case .about:      return "About"
        case .none:       return nil
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let sec = Section(rawValue: indexPath.section) else { return }

        switch sec {
        case .account:
            guard let row = AccountRow(rawValue: indexPath.row) else { return }
            switch row {
            case .verifyEmailIfNeeded:
                if let user = Auth.auth().currentUser, !user.isEmailVerified {
                    resendVerificationEmail()
                }
            case .signOut:
                signOut()
            case .email:
                break
            }
        case .appearance, .about:
            break
        }
    }

    @objc private func themeChanged(_ sender: UISegmentedControl) {
        guard let pref = ThemePreference(rawValue: sender.selectedSegmentIndex) else { return }
        ThemePreference.apply(pref)
    }
}
