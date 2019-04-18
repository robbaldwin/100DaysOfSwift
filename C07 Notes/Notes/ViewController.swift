//
//  ViewController.swift
//  Notes
//
//  Created by Rob Baldwin on 15/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var editButton: UIBarButtonItem!
    var noteCountLabel: UILabel!
    
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    var selectedNoteId: String!
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // loadData & filterResults are called in viewWillAppear as they need to be called on first load AND when returning back each time from the DetailVC
        loadData()
        filterResults()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.object(forKey: "notes") as? Data {
            let decoder = JSONDecoder()
            do {
                notes = try decoder.decode([Note].self, from: data)
            } catch {
                print("Failed to load notes")
            }
        } else {
            // Load sample notes on first load of App only
            notes = Note.sampleData()
            save()
        }
    }
    
    func configureUI() {
        
        // Background texture as used in the Notes App
        let backgroundImage = UIImage(named: "background")
        let imageView = UIImageView(image: backgroundImage)
        tableView.backgroundView = imageView
        
        // Hides seperator lines on unused cells
        tableView.tableFooterView = UIView()
        
        // Match rowHeight in Notes App
        tableView.rowHeight = 73.0

        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true

        // Match editButton in Notes App, including heavier font
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        editButton.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium)], for: .normal)
        navigationItem.rightBarButtonItem = editButton
        
        // Match the small "X Notes" label in toolBar
        noteCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 21))
        noteCountLabel.font = UIFont.systemFont(ofSize: 11)
        noteCountLabel.textColor = UIColor(named: "titleColor")
        noteCountLabel.center = CGPoint(x: view.frame.midX, y: view.frame.height)
        noteCountLabel.textAlignment = .center
        
        // Configure the toolBar at the bottom of the screen
        let toolBarText = UIBarButtonItem(customView: noteCountLabel)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let compose = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeTapped))
        toolbarItems = [flexSpace, toolBarText, flexSpace, compose]
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        // Match 'Cancel' button in Notes App searchBar
        let cancelButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        cancelButton.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "tintColor")!,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .medium)
            ], for: .normal)
        
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    func filterResults() {
        guard let searchBarText = searchController.searchBar.text?.lowercased() else {
            tableView.reloadData()
            return
        }
        
        if searchBarText.isEmpty {
            filteredNotes = notes
        } else {
            filteredNotes = notes.filter {
                $0.text.lowercased().contains(searchBarText)
            }
        }
        
        filteredNotes = filteredNotes.sorted { $0.date > $1.date }
        tableView.reloadData()
        updateNoteCountLabel()
    }
    
    func updateNoteCountLabel() {
        noteCountLabel.text = "\(filteredNotes.count) Notes"
    }
    
    @objc
    func composeTapped() {
        // Create a new note, and use the ID as the current selectedNoteID, before segue to the DetailVC.  This is necessary as selecting as existing note passes the ID to the DetailVC.
        let note = Note(id: UUID().uuidString, text: "", date: Date())
        notes.append(note)
        save()
        selectedNoteId = note.id
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    @objc
    func editTapped() {
        // Toggles editing mode and button title
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editButton.title = "Edit"
        } else {
            tableView.setEditing(true, animated: true)
            editButton.title = "Cancel"
        }
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let savedData = try? encoder.encode(notes) {
            UserDefaults.standard.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes")
        }
    }
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as? NoteCell else {
            fatalError("Unable to dequeue a NoteCell")
        }
        
        // Set cell selection color to match the Notes App selection
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "cellSelection")
        cell.selectedBackgroundView = backgroundView

        let note = filteredNotes[indexPath.row]
        cell.title.text = note.title()
        cell.date.text = note.dateString()
        cell.subTitle.text = note.subTitle()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedNoteId = filteredNotes[indexPath.row].id
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let selectedNoteId = filteredNotes[indexPath.row].id
            
            // As we are using the 'filteredNotes' array to populate the tableView, we also need to find the index of the item to delete in the full 'notes' array.
            // This searches the 'notes' array for the ID, and then removes the object from both arrays, and then deletes that one row from the tableView.
            // We could just remove the object from 'notes' and call filterResults() which would call reloadData(), but deleting the individual row gives a much nicer animation
            
            if let indexOfNoteToDelete = notes.firstIndex(where: { $0.id == selectedNoteId }) {
                filteredNotes.remove(at: indexPath.row)
                notes.remove(at: indexOfNoteToDelete)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                updateNoteCountLabel()
                save()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? DetailViewController else { return }
        vc.selectedNoteId = selectedNoteId
    }
    
    // MARK: - SearchBar
    
    func updateSearchResults(for searchController: UISearchController) {
        filterResults()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterResults()
    }
}
