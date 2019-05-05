//
//  ViewController.swift
//  SecretSwift
//
//  Created by Rob Baldwin on 04/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController, PasswordManagerDelegate {

    @IBOutlet var secretTextView: UITextView!
    
    var passwordManager: PasswordManager!
    var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove Password
        // KeychainWrapper.standard.removeObject(forKey: "password")

        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        
        // Challange 2: Create a password system for your app so that the Touch ID/Face ID fallback is more useful.
        passwordManager = PasswordManager(controller: self)
        passwordManager.delegate = self
        if !passwordManager.isPasswordCreated() {
            passwordManager.createPassword()
        }
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secretTextView.contentInset = .zero
        } else {
            secretTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secretTextView.scrollIndicatorInsets = secretTextView.contentInset
        
        let selectedRange = secretTextView.selectedRange
        secretTextView.scrollRangeToVisible(selectedRange)
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        authenticateWithBiometrics()
    }
    
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Identify yourself!" // For TouchID only
            // For FaceID add Info.plist: Privacy - Face ID Usage Description
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        guard let error = authenticationError as? LAError else { return }
                        
                        switch error.code {
                        case .userFallback:
                            self?.passwordManager.requirePassword()
                        default:
                            self?.showAuthenticationError(title: "Authentication Failed", message: "You could not be verified")
                        }
                    }
                }
            }
        } else {
            showAuthenticationError(title: "Biometrics unavailable", message: "Your device is not configured for biometric authentication")
        }
    }

    
    func showAuthenticationError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in
            self?.authenticateWithBiometrics()
        }))
        present(ac, animated: true)
    }

    func unlockSecretMessage() {
        
        // Challenge 1: Add a Done button as a navigation bar item that causes the app to re-lock immediately rather than waiting for the user to quit. This should only be shown when the app is unlocked.
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        navigationItem.rightBarButtonItem = doneButton

        secretTextView.isHidden = false
        title = "Secret stuff!"
        secretTextView.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }
    
    @objc func saveSecretMessage() {
        guard !secretTextView.isHidden else { return }
        
        KeychainWrapper.standard.set(secretTextView.text, forKey: "SecretMessage")
        secretTextView.resignFirstResponder()
        secretTextView.isHidden = true
        title = "Nothing to see here"
        
        // Challenge 1: Remove the done button
        navigationItem.rightBarButtonItem = nil
    }
    
    // MARK: - Password Manager Delegate Methods
    
    func newPasswordCreationSuccessful() {
        print("Password Creation Successful")
    }
    
    func passwordDidAuthenticate() {
        print("Password authenticated")
        unlockSecretMessage()
    }
}
