//
//  DetailViewController.swift
//  Notes
//
//  Created by Rob Baldwin on 15/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var textView: UITextView!
    
    var notes: [Note] = []
    var selectedNoteId: String!
    var selectedNote: Note!
    var shareButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        textView.delegate = self
        configureUI()
        configureKeyboardObservers()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // This is called when the Back button is tapped, and makes sure that the current data is saved
        save()
    }
    
    func configureUI() {
        
        // Configures the Nav Bar buttons (top)
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItems = [shareButton]
        
        // Configures the ToolBar buttons (bottom)
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        let compose = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [delete, flexSpace, compose]
    }
    
    func configureKeyboardObservers() {
        
        // To resize the textView when the keyboard shows or hides
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func loadData() {
        
        if let data = UserDefaults.standard.object(forKey: "notes") as? Data {
            let decoder = JSONDecoder()
            do {
                notes = try decoder.decode([Note].self, from: data)
                notes = notes.sorted { $0.date > $1.date }
            } catch {
                print("Failed to load notes")
            }
        }
        
        if let note = notes.first(where: { $0.id == selectedNoteId }) {
            // 'selectedNote' is a reference to an object within the notes array.  This is why Note is a class (reference type), rather than a struct (value type).
            selectedNote = note
        } else {
            print("Selected note not found")
        }
        
        updateTextView()
        
        // In the Notes App, the keyboard is automatically activated if the note text is empty.
        if selectedNote.text.isEmpty {
            textView.becomeFirstResponder()
        }
    }
    
    func updateTextView() {

        // Increases the default line spacing in the textView, and sets the font size and color
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributes = [
            NSAttributedString.Key.paragraphStyle : paragraphStyle,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor : UIColor(named: "titleTextColor")!
        ]
        textView.attributedText = NSAttributedString(string: selectedNote.text, attributes: attributes)
    }
    
    func save() {
        
        // 'selectedNote' is a reference to an object within the notes array.  This is why Note is a class (reference type), rather than a struct (value type).  Here the current text from the textView is stored back into the selectedNote which is a reference to an object in the notes array, which is therefore automatically updated - and the 'notes' array can just be saved
        
        if let text = textView.text {
            selectedNote.text = text
        }
        
        let encoder = JSONEncoder()
        if let savedData = try? encoder.encode(notes) {
            UserDefaults.standard.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes")
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    @objc
    func shareTapped() {
        let ac = UIActivityViewController(activityItems: [selectedNote.text], applicationActivities: [])
        present(ac, animated: true)
    }
    
    @objc
    func doneTapped() {
        textView.resignFirstResponder()
    }
    
    @objc
    func deleteTapped() {
        // Finds the index in the 'notes' array for the selectedNote
        // Gets the index of the next note to be displayed
        if let indexOfNoteToDelete = notes.firstIndex(where: { $0.id == selectedNoteId }) {
            let newIndex = notes.index(after: indexOfNoteToDelete)
            
            // Displays the next note if it exists, else pop the VC
            if notes.indices.contains(newIndex) {
                selectedNote = notes[newIndex]
                selectedNoteId = selectedNote.id
                updateTextView()
            } else {
                navigationController?.popViewController(animated: true)
            }
            // Finally, remove the deleted object from the 'notes' array
            notes.remove(at: indexOfNoteToDelete)
        }
    }
    
    @objc
    func composeTapped() {
        // Like in the Notes App, the user can create a new note when already displaying an existing note, by tapped the compose button
        
        // Save the existing data and create a new note
        save()
        let newNote = Note(id: UUID().uuidString, text: "", date: Date())
        notes.append(newNote)
        selectedNoteId = newNote.id
        selectedNote = newNote
        
        // Display the new note and activate the keyboard
        updateTextView()
        textView.becomeFirstResponder()
    }
    
    // MARK: - TextView

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        navigationItem.rightBarButtonItems = [doneButton, shareButton]
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        navigationItem.rightBarButtonItems = [shareButton]
        return true
    }
}
