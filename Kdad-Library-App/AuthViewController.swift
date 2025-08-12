//
//  AuthViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/10/25.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {

    // MARK: UI Elements

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "library_background"))
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "library_logo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Kdad Library"
        label.font = .boldSystemFont(ofSize: 26)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover your next great read"
        label.font = .italicSystemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email address"
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.borderStyle = .roundedRect
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password (min 6 characters)"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var passwordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }()

    private let toggleSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Sign In", "Register"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign In", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
        btn.backgroundColor = UIColor.systemIndigo
        btn.tintColor = .white
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        setupActions()
        setupDismissKeyboardGesture()
        configurePasswordToggleButton()
    }

    // MARK: UI Setup

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        view.addSubview(welcomeLabel)
        view.addSubview(taglineLabel)
        view.addSubview(toggleSegmentedControl)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(actionButton)
        view.addSubview(errorLabel)

        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 130),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),

            welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            taglineLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 6),
            taglineLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            taglineLabel.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),

            toggleSegmentedControl.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 40),
            toggleSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            toggleSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            emailTextField.topAnchor.constraint(equalTo: toggleSegmentedControl.bottomAnchor, constant: 24),
            emailTextField.leadingAnchor.constraint(equalTo: toggleSegmentedControl.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: toggleSegmentedControl.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            actionButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 50),

            errorLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor),
        ])
    }

    // MARK: Actions Setup

    private func setupActions() {
        toggleSegmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
    }

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configurePasswordToggleButton() {
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    }

    // MARK: Button Actions

    @objc private func didChangeSegment() {
        errorLabel.isHidden = true
        if toggleSegmentedControl.selectedSegmentIndex == 0 {
            actionButton.setTitle("Sign In", for: .normal)
            // Sign In mode stays here
        } else {
            // Present Register screen on selecting Register
            let registerVC = RegisterViewController()
            registerVC.modalPresentationStyle = .fullScreen
            present(registerVC, animated: true)
            toggleSegmentedControl.selectedSegmentIndex = 0
        }
    }

    @objc private func didTapAction() {
        errorLabel.isHidden = true

        guard let email = emailTextField.text, isValidEmail(email) else {
            showError("Please enter a valid email address.")
            return
        }

        guard let password = passwordTextField.text, password.count >= 6 else {
            showError("Password must be at least 6 characters.")
            return
        }

        // Firebase sign-in
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                self.showError(error.localizedDescription)
                return
            }

            // Sign-in success
            DispatchQueue.main.async {
                // Navigate to main app screen or dismiss auth
                print("Signed in successfully: \(email)")
                // For example:
                // self.dismiss(animated: true)
                // or navigate to main tab bar or home screen
            }
        }
    }

    // MARK: Helper Methods

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    // MARK: Toggle password visibility

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
