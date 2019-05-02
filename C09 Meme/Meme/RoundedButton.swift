//
//  RoundedButton.swift
//  Meme
//
//  Created by Rob Baldwin on 02/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}
