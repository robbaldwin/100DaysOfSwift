//
//  WordsViewController.swift
//  Pairs
//
//  Created by Rob Baldwin on 11/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import LocalAuthentication
import UIKit

class WordsViewController: UITableViewController, PasswordManagerDelegate {

    var words = [String]()
    var passwordManager: PasswordManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordManager = PasswordManager(controller: self)
        passwordManager.delegate = self
        authenticate()
    }
    
    func authenticate() {
        
        guard passwordManager.isPasswordCreated() else {
            passwordManager.createPassword()
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Identify yourself!" // For TouchID only
            // For FaceID add Info.plist: Privacy - Face ID Usage Description
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.loadWords()
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
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        ac.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in
            self?.authenticate()
        }))
        
        present(ac, animated: true)
    }
    
    func loadWords() {
        words = UserDefaults.standard.value(forKey: "words") as? [String] ?? Default.words
        words.sort { $0 < $1 }
        tableView.reloadData()
    }
    
    func save() {
        UserDefaults.standard.set(words, forKey: "words")
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Add Word", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "Enter Word"
            textfield.autocapitalizationType = .words
            textfield.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let text = ac.textFields?[0].text, !text.isEmpty else { return }
            
            if self.words.contains(text) {
                self.showAlert("Duplicates not allowed")
                return
            } else {
                self.words.append(text)
                self.words.sort { $0 < $1 }
                self.save()
                self.tableView.reloadData()
            }

        }))
        present(ac, animated: true)
    }
    
    func showAlert(_ title: String) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = words[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ac = UIAlertController(title: "Edit Word", message: nil, preferredStyle: .alert)
        ac.addTextField { textfield in
            textfield.placeholder = "Enter Word"
            textfield.autocapitalizationType = .words
            textfield.text = self.words[indexPath.row]
            textfield.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            guard let text = ac.textFields?[0].text, !text.isEmpty else { return }
            self.words[indexPath.row] = text
            self.words.sort { $0 < $1 }
            self.save()
            self.tableView.reloadData()
        }))
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard words.count > 9 else {
                showAlert("Cannot have less then 9 words")
                return
            }
            words.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            save()
        }
    }
    
    // MARK: - Password Manager Delegate Methods
    
    func newPasswordCreationSuccessful() {
        print("Password Creation Successful")
        loadWords()
    }
    
    func passwordDidAuthenticate() {
        print("Password authenticated")
        loadWords()
    }
}
