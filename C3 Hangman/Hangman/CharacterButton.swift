//
//  CharacterButton.swift
//  Hangman
//
//  Created by Rob Baldwin on 14/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class CharacterButton: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = 15.0
        self.clipsToBounds = true
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
}
