//
//  ViewController.swift
//  Debugging
//
//  Created by Rob Baldwin on 06/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("I'm inside the viewDidLoad() method!")
//        print(1, 2, 3, 4, 5)
//        print(1, 2, 3, 4, 5, separator: "-")
//        print("Some message", terminator: "")
        
//        assert(1 == 1, "Maths failure!")
//        assert(1 == 2, "Maths failure!")
        
//        assert(myReallySlowMethod() == true, "The slow method returned false, which is a bad thing!")
        
        // Breakpoints
        for i in 1...100 {
            print("Got number \(i).")
        }
    }
    
//    func myReallySlowMethod() -> Bool {
//        return false
//    }
}
