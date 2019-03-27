//
//  RoundedButton.swift
//  Instafilter
//
//  Created by Rob Baldwin on 25/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.clipsToBounds = true
    }
}
