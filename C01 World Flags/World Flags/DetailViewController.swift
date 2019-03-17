//
//  DetailViewController.swift
//  World Flags
//
//  Created by Rob Baldwin on 07/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var selectedCountry: Country!
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = selectedCountry.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        imageView.image = UIImage(named: selectedCountry.code.lowercased())
    }
    
    @objc
    func shareButtonTapped() {
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.8) else {
            return
        }
        let activityVC = UIActivityViewController(activityItems: [selectedCountry.name, imageData], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
}
