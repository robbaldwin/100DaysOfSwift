//
//  ViewController.swift
//  Instafilter
//
//  Created by Rob Baldwin on 24/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private var currentImage: UIImage!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var intensity: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
    }
    
    @objc
    private func importPicture() {
        
        // Requires: Info.plist entry
        // Privacy - Photo Library Additions Usage Description
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction private func changeFilterButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction private func intensityChanged(_ sender: Any) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true, completion: nil)
        currentImage = image
    }
}
