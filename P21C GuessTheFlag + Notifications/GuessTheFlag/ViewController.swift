//
//  ViewController.swift
//  GuessTheFlag
//
//  Created by Rob Baldwin on 07/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit
import UserNotifications

final class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    var countries: [String] = []
    var score: Int = 0
    var correctAnswer = 0
    var questionsAsked = 0
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        loadCountriesArray()
        registerNotifications()
        askQuestion()
    }
    
    func configureButtons() {
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func loadCountriesArray() {
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    }
    
    // P21 Challenge 3: And for an even harder challenge, update project 2 so that it reminds players to come back and play every day. This means scheduling a week of notifications ahead of time, each of which launch the app. When the app is finally launched, make sure you call

    func registerNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if granted {
                self?.setupNewNotifications()
            } else {
                print("Authorised Denied")
            }
        }
    }
    
    func setupNewNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Hey, we miss you!"
        content.body = "There are still lots of flags waiting to be guessed"
        content.categoryIdentifier = "comeBack"
        content.sound = .default
        
        let play = UNNotificationAction(identifier: "play", title: "Play now", options: .foreground)
        
        let category = UNNotificationCategory(identifier: "comeBack", actions: [play], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
        
        // Add trigger every day for 7 days, 24 hours from now
        // Using 5 seconds for testing - 24 hours = 86400
        let timeInterval = 5 // 86400
        
        for i in 1...7 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (TimeInterval(timeInterval * i)), repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
    }
    
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        updateNavigationBarTitle()
    }
    
    func updateNavigationBarTitle() {
        let country = countries[correctAnswer].uppercased()
        title = "\(country) 🏅\(score)"
    }
    
    func checkAnswer(answer: Int) {
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
    
    func showFinalScore() {
        showAlert(title: "Game Over", message: "Your final score is \(score)", buttonTitle: "Play Again") {
            self.score = 0
            self.questionsAsked = 0
            self.askQuestion()
        }
    }
    
    func showAlert(title: String, message: String?, buttonTitle: String, action: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { _ in
            action()
        }))
        present(alertController, animated: true)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        checkAnswer(answer: sender.tag)
    }
}
