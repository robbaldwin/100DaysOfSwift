//
//  PersonCell.swift
//  NamesToFaces
//
//  Created by Rob Baldwin on 16/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class PersonCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        imageView.layer.borderColor = UIColor(red: 41/255, green: 50/255, blue: 55/255, alpha: 0.5).cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 3
        imageView.clipsToBounds = true
        self.layer.cornerRadius = 7
    }
}
