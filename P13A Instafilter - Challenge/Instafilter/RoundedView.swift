//
//  RoundedView.swift
//  Instafilter
//
//  Created by Rob Baldwin on 25/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class RoundedView: UIView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
    }
}
