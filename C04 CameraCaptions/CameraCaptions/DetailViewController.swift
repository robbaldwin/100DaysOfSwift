//
//  DetailViewController.swift
//  CameraCaptions
//
//  Created by Rob Baldwin on 23/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class DetailViewController: UIViewController {
    
    @IBOutlet var photoImageView: UIImageView!
    
    var photo: Photo!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
    }
    
    private func loadImage() {
        let path = getDocumentsDirectory().appendingPathComponent(photo.filename)
        photoImageView.image = UIImage(contentsOfFile: path.path)
        title = photo.caption
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
