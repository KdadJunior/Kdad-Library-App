//
//  ForgotPasswordViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/12/25.
//

import Foundation
import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

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

    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email to reset your password"
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .label
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

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send Reset Link", for: .normal)
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

    private let successLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGreen
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Back to Sign In", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.tintColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        setupActions()
        setupDismissKeyboardGesture()
    }

    // MARK: UI Setup

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(logoImageView)
        view.addSubview(instructionLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendButton)
        view.addSubview(errorLabel)
        view.addSubview(successLabel)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 130),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),

            instructionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            emailTextField.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: instructionLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: instructionLabel.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 32),
            sendButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            sendButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: 50),

            errorLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor),

            successLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 12),
            successLabel.leadingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            successLabel.trailingAnchor.constraint(equalTo: sendButton.trailingAnchor),

            backButton.topAnchor.constraint(equalTo: successLabel.bottomAnchor, constant: 20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: Actions Setup

    private func setupActions() {
        sendButton.addTarget(self, action: #selector(didTapSendResetLink), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: Button Actions

    @objc private func didTapSendResetLink() {
        errorLabel.isHidden = true
        successLabel.isHidden = true

        guard let email = emailTextField.text, isValidEmail(email) else {
            showError("Please enter a valid email address.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.showError("Failed to send reset link: \(error.localizedDescription)")
            } else {
                self.successLabel.text = "Password reset link sent! Please check your email."
                self.successLabel.isHidden = false
            }
        }
    }

    @objc private func didTapBack() {
        dismiss(animated: true)
    }

    // MARK: Helper Methods

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        successLabel.isHidden = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }
}
