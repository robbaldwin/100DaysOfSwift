//
//  ViewController.swift
//  Meme
//
//  Created by Rob Baldwin on 02/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedImage: UIImage?
    var topCaption: String?
    var bottomCaption: String?
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meme"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage))
        let share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteImage))
        
        navigationItem.leftBarButtonItem = delete
        navigationItem.rightBarButtonItems = [add, share]
    }
    
    func updateImage() {
        
        let renderer = UIGraphicsImageRenderer(size: imageView.frame.size)

        let image = renderer.image { ctx in

            selectedImage?.draw(in: CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            // ADDING A CUSTOM FONT
            // Add .ttf or .otf file to Project
            // Make sure included in Target
            // Make sure included in Build Phases > Copy Bundle Resources
            // Info.plist: Fonts provided by Application
            //      Item 0      Anton.ttf
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font : UIFont(name: "Anton", size: 40)!,
                .foregroundColor : UIColor.white,
                .strokeWidth : -3.0,
                .strokeColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]

            if let topCaption = topCaption {
                let attributedString = NSAttributedString(string: topCaption, attributes: attrs)
                
                attributedString.draw(with: CGRect(x: 0, y: 5, width: imageView.frame.size.width, height: 200), options: .usesLineFragmentOrigin, context: nil)
            }
            
            if let bottomCaption = bottomCaption {
                let attributedString = NSAttributedString(string: bottomCaption, attributes: attrs)
                
                attributedString.draw(with: CGRect(x: 0, y: imageView.frame.height - 65, width: imageView.frame.size.width, height: 200), options: .usesLineFragmentOrigin, context: nil)
            }
        }
        
        imageView.image = image
    }
    
    @objc func addImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func shareImage() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
    
    @objc func deleteImage() {
        selectedImage = nil
        topCaption = nil
        bottomCaption = nil
        updateImage()
    }
    
    @IBAction func topCaptionButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Top Caption", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter Caption"
            textField.autocapitalizationType = .allCharacters
            textField.font = UIFont.systemFont(ofSize: 20)
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac, weak self] _ in
            guard let caption = ac?.textFields?[0].text else { return }
            self?.topCaption = caption
            self?.updateImage()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func bottomCaptionButtonTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Bottom Caption", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter Caption"
            textField.autocapitalizationType = .allCharacters
            textField.font = UIFont.systemFont(ofSize: 20)
        }
        ac.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak ac, weak self] _ in
            guard let caption = ac?.textFields?[0].text else { return }
            self?.bottomCaption = caption
            self?.updateImage()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        selectedImage = image
        dismiss(animated: true)
        updateImage()
    }
}
