//
//  ViewController.swift
//  CameraCaptions
//
//  Created by Rob Baldwin on 23/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 90.0
        configureNavBar()
        loadPhotos()
    }

    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
    }
    
    private func loadPhotos() {
        
        guard let photosData = UserDefaults.standard.object(forKey: "photos") as? Data else {
            print("No Photos Found")
            return
        }
        
        let jsonDecoder = JSONDecoder()
        
        do {
            photos = try jsonDecoder.decode([Photo].self, from: photosData)
        } catch {
            print("Failed to load photos")
        }
    }
    
    @objc
    private func takePhoto() {
        
        // Info.plist entry required !
        // Privacy - CameraUsageDescription
        // The App requires access to your camera to take photos
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true)        
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func savePhotos() {
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let photosData = try jsonEncoder.encode(photos)
            UserDefaults.standard.set(photosData, forKey: "photos")
        } catch {
            print("Failed to save photos")
        }
    }
    
    // MARK: - ImagePicker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        dismiss(animated: true) { [weak self] in
            let ac = UIAlertController(title: "Caption", message: nil, preferredStyle: .alert)
            ac.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Enter Caption"
                textField.autocapitalizationType = .sentences
                textField.font = UIFont.systemFont(ofSize: 20.0)
            })
            ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self, weak ac] _ in
                guard let caption = ac?.textFields?[0].text else { return }
                let photo = Photo(filename: imageName, caption: caption)
                self?.photos.append(photo)
                self?.savePhotos()
                self?.tableView.reloadData()
            }))
            self?.present(ac, animated: true)
        }
    }
    
    // MARK: - TableView DataSource & Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
    
        let photo = photos[indexPath.row]
        cell.textLabel?.text = photo.caption
        
        let path = getDocumentsDirectory().appendingPathComponent(photo.filename)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.image = UIImage(contentsOfFile: path.path)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            fatalError("Unable to instantiate DetailViewController")
        }
        vc.photo = photos[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            photos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            savePhotos()
        }
    }
}
