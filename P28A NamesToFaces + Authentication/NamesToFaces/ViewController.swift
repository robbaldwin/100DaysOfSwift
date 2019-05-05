//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Rob Baldwin on 16/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PasswordManagerDelegate {

    var people: [Person] = []
    var passwordManager: PasswordManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEntersBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appEntersForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        passwordManager = PasswordManager(controller: self)
        passwordManager.delegate = self
        authenticate()
    }
    
    @objc func authenticate() {

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
                        self?.loadPeople()
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
            self?.authenticate()
        }))
        present(ac, animated: true)
    }
    
    @objc func appEntersBackground() {
        people.removeAll()
        collectionView.reloadData()
    }
    
    @objc func appEntersForeground() {
        authenticate()
    }

    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        //picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func renamePerson(index: Int) {
        let person = people[index]
        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            self?.savePeople()
            self?.collectionView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: - CollectionView Datasource & Delegate
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        let person = people[indexPath.item]
        cell.nameLabel.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Select Action", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.collectionView.reloadData()
        }))
        ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak self] _ in
            self?.renamePerson(index: indexPath.item)
        }))
        present(ac, animated: true)
    }
    
    // MARK: - ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        savePeople()
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
    func savePeople() {
        let jsonEncoder = JSONEncoder()
        if let data = try? jsonEncoder.encode(people) {
            KeychainWrapper.standard.set(data, forKey: "people")
        } else {
            print("Failed to save the people.")
        }
    }
    
    func loadPeople() {
        let jsonDecoder = JSONDecoder()
        if let data = KeychainWrapper.standard.data(forKey: "people") {
            do {
                people = try jsonDecoder.decode([Person].self, from: data)
                collectionView.reloadData()
            } catch {
                print("Failed to load the people")
            }
        }
    }
    
    // MARK: - Password Manager Delegate Methods
    
    func newPasswordCreationSuccessful() {
        print("Password Creation Successful")
        loadPeople()
    }
    
    func passwordDidAuthenticate() {
        print("Password authenticated")
        loadPeople()
    }
}
