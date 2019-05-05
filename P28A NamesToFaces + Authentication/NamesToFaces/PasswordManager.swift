//
//  PasswordManager.swift
//  SecretSwift
//
//  Created by Rob Baldwin on 05/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

// Challange 2: Create a password system for your app so that the Touch ID/Face ID fallback is more useful.

protocol PasswordManagerDelegate: class {
    func newPasswordCreationSuccessful()
    func passwordDidAuthenticate()
}

enum PasswordCreationError: String {
    case blank = "Password cannot be blank"
    case tooShort = "Password is too short"
    case doNotMatch = "Passwords do not match"
}

enum PasswordEntryError: String {
    case blank = "You must enter the password"
    case incorrect = "That is the wrong password"
}

struct PasswordManager {
    
    weak var delegate: PasswordManagerDelegate?
    weak var controller: ViewController?
    
    init(controller: ViewController) {
        self.controller = controller
    }
    
    func isPasswordCreated() -> Bool {
        return KeychainWrapper.standard.hasValue(forKey: "password")
    }
    
    func createPassword() {
        let ac = UIAlertController(title: "Create Password", message: "Must be at least 6 characters", preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.font = UIFont.systemFont(ofSize: 20)
            textfield.isSecureTextEntry = true
            textfield.placeholder = "Enter Password"
        }
        ac.addTextField { textfield in
            textfield.font = UIFont.systemFont(ofSize: 20)
            textfield.isSecureTextEntry = true
            textfield.placeholder = "Confirm Password"
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac] _ in
            guard let password1 = ac?.textFields?[0].text else {
                self.showPasswordCreationErrorAlert(.blank)
                return
            }
            guard let password2 = ac?.textFields?[1].text else {
                self.showPasswordCreationErrorAlert(.blank)
                return
            }
            self.verifyNewPassword((first: password1, second: password2))
        }))
        controller?.present(ac, animated: true)
    }
    
    private func verifyNewPassword(_ passwords: (first: String, second: String)) {
        
        if passwords.first != passwords.second {
            showPasswordCreationErrorAlert(.doNotMatch)
        } else if passwords.first.count < 6 {
            showPasswordCreationErrorAlert(.tooShort)
        } else {
            KeychainWrapper.standard.set(passwords.first, forKey: "password")
            showPasswordCreatedAlert()
        }
    }
    
    private func showPasswordCreationErrorAlert(_ error: PasswordCreationError) {
        let ac = UIAlertController(title: error.rawValue, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.createPassword()
        }))
        controller?.present(ac, animated: true)
    }
    
    private func showPasswordCreatedAlert() {
        let ac = UIAlertController(title: "Password Created", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.delegate?.newPasswordCreationSuccessful()
        }))
        controller?.present(ac, animated: true)
    }
    
    func requirePassword() {
        let ac = UIAlertController(title: "Enter Password", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.font = UIFont.systemFont(ofSize: 20)
            textfield.isSecureTextEntry = true
            textfield.placeholder = "Password"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] _ in
            guard let enteredPassword = ac?.textFields?[0].text else {
                self.showPasswordEntryError(.blank)
                return
            }
            if let password = KeychainWrapper.standard.string(forKey: "password") {
                if enteredPassword != password {
                    self.showPasswordEntryError(.incorrect)
                    return
                } else if enteredPassword.isEmpty {
                    self.showPasswordEntryError(.blank)
                } else {
                    self.delegate?.passwordDidAuthenticate()
                }
            }
        }))
        controller?.present(ac, animated: true)
    }
    
    func showPasswordEntryError(_ error: PasswordEntryError) {
        let ac = UIAlertController(title: error.rawValue, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.requirePassword()
        }))
        controller?.present(ac, animated: true)
    }
}
