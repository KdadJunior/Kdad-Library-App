//
//  RegisterViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/10/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {

    private let db = Firestore.firestore()

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
        tf.textContentType = .oneTimeCode
        tf.autocorrectionType = .no
        tf.smartInsertDeleteType = .no
        tf.smartQuotesType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let reenterPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Re-enter Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.textContentType = .oneTimeCode
        tf.autocorrectionType = .no
        tf.smartInsertDeleteType = .no
        tf.smartQuotesType = .no
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
    
    // New: Resend verification button, hidden by default
    private let resendVerificationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Resend Verification Email", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.tintColor = .systemBlue
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isHidden = true
        return btn
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
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
        contentView.addSubview(resendVerificationButton)  // Add resend button to contentView
        actionButton.addSubview(loadingIndicator)

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

            resendVerificationButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
            resendVerificationButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: -16),

            contentView.bottomAnchor.constraint(equalTo: resendVerificationButton.bottomAnchor, constant: 20)
        ])
    }

    // MARK: Actions Setup

    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        resendVerificationButton.addTarget(self, action: #selector(didTapResendVerification), for: .touchUpInside)
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
        // Hide previous errors and disable sign up button, show loading
        actionButton.isEnabled = false
        loadingIndicator.startAnimating()
        resendVerificationButton.isHidden = true

        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Name Required", message: "Please enter your name.")
            finishLoading()
            return
        }

        guard let email = emailTextField.text, isValidEmail(email) else {
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            finishLoading()
            return
        }

        guard let reEmail = reenterEmailTextField.text, reEmail == email else {
            showAlert(title: "Email Mismatch", message: "Email addresses do not match.")
            finishLoading()
            return
        }

        guard let password = passwordTextField.text, isStrongPassword(password) else {
            showAlert(title: "Weak Password", message: "Password must be at least 6 characters and contain uppercase, lowercase, digit, and special character.")
            finishLoading()
            return
        }

        guard let rePassword = reenterPasswordTextField.text, rePassword == password else {
            showAlert(title: "Password Mismatch", message: "Passwords do not match.")
            finishLoading()
            return
        }

        // Firebase create user
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            print("DEBUG: createUser authResult: \(String(describing: authResult))")
            print("DEBUG: createUser error: \(String(describing: error))")

            if let error = error {
                self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                self.finishLoading()
                return
            }

            guard let user = authResult?.user else {
                let debugMessage = """
                Registration failed:
                authResult: \(String(describing: authResult))
                error: \(String(describing: error))
                """
                self.showAlert(title: "Registration Failed", message: debugMessage)
                self.finishLoading()
                return
            }

            // Save additional user info in Firestore
            self.db.collection("users").document(user.uid).setData([
                "name": name,
                "email": email,
                "createdAt": Timestamp(date: Date())
            ]) { err in
                if let err = err {
                    self.showAlert(title: "Data Save Failed", message: err.localizedDescription)
                    self.finishLoading()
                } else {
                    // Send email verification
                    user.sendEmailVerification { verificationError in
                        if let verificationError = verificationError {
                            self.showAlert(title: "Verification Email Failed", message: verificationError.localizedDescription)
                            self.finishLoading()
                        } else {
                            self.finishLoading()
                            self.showAlert(title: "Registration Successful", message: "Please check your email to verify your account.") {
                                // Show resend button after success to allow resending if needed
                                self.resendVerificationButton.isHidden = false
                                self.dismiss(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Resend Verification

    @objc private func didTapResendVerification() {
        guard let user = Auth.auth().currentUser, !user.isEmailVerified else {
            showAlert(title: "Already Verified", message: "Your email is already verified.")
            return
        }

        user.sendEmailVerification { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Resend Failed", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "Email Sent", message: "Verification email resent successfully.")
            }
        }
    }

    // MARK: Password Strength Validation

    private func isStrongPassword(_ password: String) -> Bool {
        // At least 6 chars, one uppercase, one lowercase, one digit, one special char
        let pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^A-Za-z\\d]).{6,}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", pattern)
        return predicate.evaluate(with: password)
    }

    // MARK: Fetch User Info (example for after login)

    func fetchUserInfo(uid: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = snapshot?.data() {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
            }
        }
    }

    // MARK: Helper Methods

    private func finishLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.actionButton.isEnabled = true
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            self.present(alertVC, animated: true)
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: email)
    }

    // MARK: Toggle password visibility

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()

        if let existingText = passwordTextField.text, passwordTextField.isFirstResponder {
            passwordTextField.text = nil
            passwordTextField.text = existingText

            if let endPosition = passwordTextField.position(from: passwordTextField.beginningOfDocument, offset: existingText.count) {
                passwordTextField.selectedTextRange = passwordTextField.textRange(from: endPosition, to: endPosition)
            }
        }

        let imageName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        passwordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func toggleReenterPasswordVisibility() {
        reenterPasswordTextField.isSecureTextEntry.toggle()

        if let existingText = reenterPasswordTextField.text, reenterPasswordTextField.isFirstResponder {
            reenterPasswordTextField.text = nil
            reenterPasswordTextField.text = existingText

            if let endPosition = reenterPasswordTextField.position(from: reenterPasswordTextField.beginningOfDocument, offset: existingText.count) {
                reenterPasswordTextField.selectedTextRange = reenterPasswordTextField.textRange(from: endPosition, to: endPosition)
            }
        }

        let imageName = reenterPasswordTextField.isSecureTextEntry ? "eye.slash" : "eye"
        reenterPasswordToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
