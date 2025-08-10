//
//  RegisterViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/10/25.
//

import UIKit

class RegisterViewController: UIViewController {

    // MARK: UI Elements

    private let backgroundImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "library_background"))
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.setTitle(" Back", for: .normal)
        btn.tintColor = .systemIndigo
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "library_logo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Your Account"
        label.font = .boldSystemFont(ofSize: 26)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.autocapitalizationType = .words
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
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

    private let reenterEmailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Re-enter Email"
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

    private let reenterPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Re-enter Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private lazy var passwordToggleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .gray
        btn.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return btn
    }()

    private lazy var reenterPasswordToggleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .gray
        btn.addTarget(self, action: #selector(toggleReenterPasswordVisibility), for: .touchUpInside)
        return btn
    }()

    private let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 20)
        btn.backgroundColor = UIColor.systemIndigo
        btn.tintColor = .white
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .systemRed
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 14)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.isHidden = true
        return lbl
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        setupActions()
        setupDismissKeyboardGesture()
        configurePasswordToggleButtons()
    }

    // MARK: UI Setup

    private func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        contentView.addSubview(logoImageView)
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(reenterEmailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(reenterPasswordTextField)
        contentView.addSubview(actionButton)
        contentView.addSubview(errorLabel)

        passwordTextField.rightView = passwordToggleButton
        passwordTextField.rightViewMode = .always

        reenterPasswordTextField.rightView = reenterPasswordToggleButton
        reenterPasswordTextField.rightViewMode = .always

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            logoImageView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 130),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),

            welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            welcomeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),

            nameTextField.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: welcomeLabel.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            reenterEmailTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            reenterEmailTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            reenterEmailTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            reenterEmailTextField.heightAnchor.constraint(equalToConstant: 44),

            passwordTextField.topAnchor.constraint(equalTo: reenterEmailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: reenterEmailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: reenterEmailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            reenterPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            reenterPasswordTextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            reenterPasswordTextField.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            reenterPasswordTextField.heightAnchor.constraint(equalToConstant: 44),

            actionButton.topAnchor.constraint(equalTo: reenterPasswordTextField.bottomAnchor, constant: 32),
            actionButton.leadingAnchor.constraint(equalTo: reenterPasswordTextField.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: reenterPasswordTextField.trailingAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 50),

            errorLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
            errorLabel.leadingAnchor.constraint(equalTo: actionButton.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: Actions Setup

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    }

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configurePasswordToggleButtons() {
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        reenterPasswordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
    }

    // MARK: Button Actions

    @objc private func didTapBack() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func didTapRegister() {
        errorLabel.isHidden = true

        guard let name = nameTextField.text, !name.isEmpty else {
            showError("Please enter your name.")
            return
        }

        guard let email = emailTextField.text, isValidEmail(email) else {
            showError("Please enter a valid email address.")
            return
        }

        guard let reEmail = reenterEmailTextField.text, reEmail == email else {
            showError("Email addresses do not match.")
            return
        }

        guard let password = passwordTextField.text, password.count >= 6 else {
            showError("Password must be at least 6 characters.")
            return
        }

        guard let rePassword = reenterPasswordTextField.text, rePassword == password else {
            showError("Passwords do not match.")
            return
        }

        // TODO: Implement registration logic here
        print("Registering user: \(name), email: \(email)")
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

    @objc private func toggleReenterPasswordVisibility() {
        reenterPasswordTextField.isSecureTextEntry.toggle()
        let imageName = reenterPasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        reenterPasswordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
