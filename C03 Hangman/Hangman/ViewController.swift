//
//  ViewController.swift
//  Hangman
//
//  Created by Rob Baldwin on 14/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet private var scoreLabel: UIBarButtonItem!
    @IBOutlet private var resetButton: UIBarButtonItem!
    @IBOutlet private var roundLabel: RoundedLabel!
    @IBOutlet private var wordLabel: UILabel!
    @IBOutlet private var hangmanImageView: UIImageView!
    
    private var words: [String]!
    private var activeWord: String = ""
    private var revealedWord: String = ""
    private var buttonsPressed: [UIButton] = []
    private var charactersGuessed: [Character] = []

    private var currentRound: Int = 0 {
        didSet {
            roundLabel.text = "Round \(currentRound)"
        }
    }
    
    private var roundsPlayed: Int = 0 {
        didSet {
            scoreLabel.title = "Won \(roundsWon) of \(roundsPlayed)"
        }
    }
    
    private var roundsWon: Int = 0 {
        didSet {
            scoreLabel.title = "Won \(roundsWon) of \(roundsPlayed)"
        }
    }
    
    private var incorrectGuesses: Int = 0 {
        didSet {
            hangmanImageView.image = UIImage(named: "hangman\(incorrectGuesses)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWords()
    }

    private func loadWords() {
        
        guard let url = Bundle.main.url(forResource: "Words", withExtension: "txt") else {
            fatalError("Unable to find Words.txt file")
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let words = try? String(contentsOf: url) else {
                fatalError("Unable to open Words.txt file")
            }
            self?.words = words.components(separatedBy: "\n")
            self?.performSelector(onMainThread: #selector(self?.newRound), with: nil, waitUntilDone: false)
        }
    }
    
    @objc
    private func newRound() {
        resetButtons()
        charactersGuessed.removeAll()
        incorrectGuesses = 0
        currentRound += 1
        wordLabel.textColor = .black
        activeWord = randomWord().uppercased()
        revealedWord = ""
        updateWordLabel()
        print(activeWord)
    }
    
    private func resetButtons() {
        
        for button in buttonsPressed {
            button.backgroundColor = CustomColor.brown
            button.setTitleColor(.white, for: .normal)
            button.isUserInteractionEnabled = true
        }
        buttonsPressed.removeAll()
    }
    
    private func randomWord() -> String {
        return words.randomElement() ?? "hacking"
    }
    
    private func updateWordLabel() {

        revealedWord = ""
        
        for character in activeWord {
            if charactersGuessed.contains(character) {
                revealedWord.append(character)
            } else {
                revealedWord.append("_")
            }
        }
        wordLabel.text = revealedWord
        wordLabel.addSpacing(kernValue: 7.0)
        checkIfGameOver()
    }
    
    private func checkIfGameOver() {
        
        if revealedWord == activeWord {
            roundsWon += 1
            roundsPlayed += 1
            wordLabel.textColor = CustomColor.green
            animateWordLabel()
            toggleUserInteraction()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.toggleUserInteraction()
                self?.newRound()
            }
        }
        
        if incorrectGuesses == 7 {
            roundsPlayed += 1
            wordLabel.text = activeWord
            wordLabel.addSpacing(kernValue: 7.0)
            wordLabel.textColor = .red
            animateWordLabel()
            toggleUserInteraction()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.toggleUserInteraction()
                self?.newRound()
            }
        }
    }
    
    private func toggleUserInteraction() {
        view.isUserInteractionEnabled.toggle()
        resetButton.isEnabled.toggle()
    }
    
    private func animateWordLabel() {
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.wordLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.wordLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
    }
    
    @IBAction private func characterButtonTapped(_ sender: UIButton) {
        buttonsPressed.append(sender)
        sender.backgroundColor = .clear
        sender.setTitleColor(.clear, for: .normal)
        sender.isUserInteractionEnabled = false

        if let buttonTitle = sender.titleLabel?.text {
            charactersGuessed.append(Character(buttonTitle))
            if !activeWord.contains(buttonTitle) {
                incorrectGuesses += 1
            }
        }
        updateWordLabel()
    }
    
    @IBAction private func resetButtonTapped(_ sender: UIBarButtonItem) {
        currentRound = 0
        roundsPlayed = 0
        roundsWon = 0
        newRound()
    }
}
