//
//  GameViewController.swift
//  Pairs
//
//  Created by Rob Baldwin on 10/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import AVFoundation
import UIKit

class GameViewController: UIViewController {
    
    var words = [String]()
    var cards = [Card]()
    var selectedCards = [Int]()
    var matchedPairs = 0
    var startTime = Date()
    var cardFlipSound: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        words = UserDefaults.standard.value(forKey: "words") as? [String] ?? Default.words
        let selectedWords = words.shuffled().prefix(upTo: 9)
        let duplicatedWords = (selectedWords + selectedWords).shuffled()
        
        for word in duplicatedWords {
            let card = Card(word: word)
            cards.append(card)
        }
    }

    func checkForMatch() {
        
        print(cards[selectedCards[0]].word)
        print(cards[selectedCards[1]].word)
        
        if cards[selectedCards[0]].word == cards[selectedCards[1]].word {
            // Matched
            cards[selectedCards[0]].isMatched = true
            cards[selectedCards[1]].isMatched = true
            selectedCards.removeAll()
            matchedPairs += 1
            if matchedPairs == 9 {
                gameOver()
            }
        } else {
            // Not Matched
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                for card in self.selectedCards {
                    if let button = self.view.viewWithTag(card + 1) as? UIButton {
                        let image = UIImage(named: "cardback")
                        let label = button.viewWithTag(100)
                        label?.removeFromSuperview()
                        button.setImage(image, for: .normal)
                        UIView.transition(with: button, duration: 0.4, options: .transitionFlipFromLeft, animations: nil, completion: nil)
                        self.cards[card].isShown = false
                    }
                }
                
                if let path = Bundle.main.path(forResource: "cardflip", ofType: "wav") {
                    let url = URL(fileURLWithPath: path)
                    do {
                        self.cardFlipSound = try AVAudioPlayer(contentsOf: url)
                        self.cardFlipSound?.play()
                    } catch  {
                        print(error.localizedDescription)
                    }
                }

                self.selectedCards.removeAll()
            }
        }
    }
    
    func gameOver() {
        let elapsedTime = Int(Date().timeIntervalSince(startTime))
        
        let ac = UIAlertController(title: "Well done", message: "You found all the pairs in \(elapsedTime) seconds", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(ac, animated: true)
    }

    @IBAction func cardTapped(_ sender: UIButton) {
        guard
            selectedCards.count < 2,
            !cards[sender.tag - 1].isShown,
            !cards[sender.tag - 1].isMatched
        else { return }
        
        if let path = Bundle.main.path(forResource: "cardflip", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            do {
                cardFlipSound = try AVAudioPlayer(contentsOf: url)
                cardFlipSound?.play()
            } catch  {
                print(error.localizedDescription)
            }
        }

        cards[sender.tag - 1].isShown = true
        selectedCards.append(sender.tag - 1)
        
        let image = UIImage(named: "cardfront")
        sender.setImage(image, for: .normal)
        
        let label = UILabel()
        label.tag = 100
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.text = cards[sender.tag - 1].word
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        sender.addSubview(label)
        
        NSLayoutConstraint.activate([
            sender.centerXAnchor.constraint(equalTo: label.centerXAnchor, constant: 0),
            sender.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0),
            label.widthAnchor.constraint(equalTo: sender.widthAnchor, constant: -5)
            ])
        
        UIView.transition(with: sender, duration: 0.4, options: .transitionFlipFromRight, animations: nil, completion: nil)
        
        if selectedCards.count == 2 {
            checkForMatch()
        }
    }
}
