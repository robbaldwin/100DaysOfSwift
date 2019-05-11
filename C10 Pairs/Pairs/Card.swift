//
//  Card.swift
//  Pairs
//
//  Created by Rob Baldwin on 11/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import Foundation

struct Card {
    var word: String
    var isShown: Bool = false
    var isMatched: Bool = false
    
    init(word: String) {
        self.word = word
    }
}
