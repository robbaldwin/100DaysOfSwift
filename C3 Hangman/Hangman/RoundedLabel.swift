//
//  RoundedLabel.swift
//  Hangman
//
//  Created by Rob Baldwin on 14/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class RoundedLabel: UILabel {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
}
