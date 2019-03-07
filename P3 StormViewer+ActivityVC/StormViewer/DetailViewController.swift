//
//  DetailViewController.swift
//  StormViewer
//
//  Created by Rob Baldwin on 07/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var selectedPicture: String!
    var pictureTitle: String!
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed))
        
        if let imageToLoad = selectedPicture {
            title = pictureTitle
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc
    private func shareButtonPressed() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        let activityVC = UIActivityViewController(activityItems: [selectedPicture, image], applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}
