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
        
        // Challange 3: Go back to project 3 and change the way the selected image is shared so that it has some rendered text on top saying “From Storm Viewer”. This means reading the size property of the original image, creating a new canvas at that size, drawing the image in, then adding your text on top.
        
        let renderer = UIGraphicsImageRenderer(size: imageView.frame.size)
        
        let image = renderer.image { ctx in
            
            let stormImage = UIImage(named: selectedPicture)
            stormImage?.draw(at: CGPoint(x: 0, y: 0))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attrs: [NSAttributedString.Key: Any] = [
                .font : UIFont.systemFont(ofSize: 30),
                .paragraphStyle: paragraphStyle
            ]

            let string = "From Storm Viewer"
            let attributedString = NSAttributedString(string: string, attributes: attrs)

            attributedString.draw(with: CGRect(x: 0, y: 40, width: imageView.frame.size.width, height: 40), options: .usesLineFragmentOrigin, context: nil)
        }
        
        imageView.image = image
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
        let activityVC = UIActivityViewController(activityItems: [selectedPicture!, image], applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}
