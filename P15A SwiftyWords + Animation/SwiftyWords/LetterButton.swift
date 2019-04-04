//
//  LetterButton.swift
//  SwiftyWords
//
//  Created by Rob Baldwin on 04/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

// Custom class to disable the default UIKit animation when the button is tapped

class LetterButton: UIButton {

    override func setTitle(_ title: String?, for state: UIControl.State) {
        
        UIView.performWithoutAnimation {
            super.setTitle(title, for: state)
            self.layoutIfNeeded()
        }
    }
}
