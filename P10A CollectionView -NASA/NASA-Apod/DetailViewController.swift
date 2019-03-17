//
//  DetailViewController.swift
//  NASA-Apod
//
//  Created by Rob Baldwin on 17/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textView: UITextView!
    
    var selectedPhoto: NASAPhoto!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedPhoto.date
        populateTextView()
        loadPhoto()
    }
    
    private func populateTextView() {
        
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let bodyAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let attrString = NSMutableAttributedString(string: "\(selectedPhoto.title)\n", attributes: titleAttributes)
        let bodyAttrString = NSMutableAttributedString(string: selectedPhoto.explanation, attributes: bodyAttributes)
        
        attrString.append(bodyAttrString)
        textView.attributedText = attrString
    }

    private func loadPhoto() {
        
        guard let selectedPhoto = selectedPhoto else { return }
        
        if let imageData = selectedPhoto.imageData {
            imageView.image = UIImage(data: imageData)
        }
    }
}
