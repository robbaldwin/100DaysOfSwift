//
//  NASAPhotoCell.swift
//  NASA-Apod
//
//  Created by Rob Baldwin on 17/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class NASAPhotoCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 7
    }
}
