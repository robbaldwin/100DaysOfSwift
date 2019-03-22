//
//  ViewController.swift
//  GuessTheFlag
//
//  Created by Rob Baldwin on 07/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    private var countries: [String] = []
    private var score: Int = 0
    private var correctAnswer: Int = 0
    private var questionsAsked: Int = 0
    private var highScore: Int = 0
    
    @IBOutlet private var button1: UIButton!
    @IBOutlet private var button2: UIButton!
    @IBOutlet private var button3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        loadCountriesArray()
        loadHighScore()
        askQuestion()
    }
    
    private func configureButtons() {
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func loadCountriesArray() {
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    }
    
    private func loadHighScore() {
        if let highScore = UserDefaults.standard.value(forKey: "highScore") as? Int {
            self.highScore = highScore
        }
    }
    
    private func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        updateNavigationBarTitle()
    }
    
    private func updateNavigationBarTitle() {
        let country = countries[correctAnswer].uppercased()
        title = "\(country) 🏅\(score)"
    }
    
    private func checkAnswer(answer: Int) {
        var title: String
        var message: String?
        
        if answer == correctAnswer {
            title = "Correct!"
            message = nil
            score += 1
        } else {
            title = "Wrong!"
            message = "That's the flag of \(countries[answer].uppercased())"
            score -= 1
        }
        questionsAsked += 1
        updateNavigationBarTitle()
        
        showAlert(title: title, message: message, buttonTitle: "Continue") {
            if self.questionsAsked < 10 {
                self.askQuestion()
            } else {
                self.showFinalScore()
            }
        }
    }
    
    private func showFinalScore() {
        
        var title: String
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore")
            title = "Game Over - New High Score!"
        } else {
            title = "Game Over"
        }
        
        showAlert(title: title, message: "Your final score is \(score)", buttonTitle: "Play Again") {
            self.score = 0
            self.questionsAsked = 0
            self.askQuestion()
        }
    }
    
    private func showAlert(title: String, message: String?, buttonTitle: String, action: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
            action()
        }))
        present(alertController, animated: true)
    }
    
    @IBAction private func buttonPressed(_ sender: UIButton) {
        checkAnswer(answer: sender.tag)
    }
}

