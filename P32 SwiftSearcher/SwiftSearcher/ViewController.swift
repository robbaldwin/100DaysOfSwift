//
//  ViewController.swift
//  SwiftSearcher
//
//  Created by Rob Baldwin on 12/05/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import CoreSpotlight
import MobileCoreServices
import SafariServices
import UIKit

class ViewController: UITableViewController {
    
    var projects = [Project]()
    var favourites = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SwiftSearcher"
        
        loadJSON()
        
        if let savedFavourites = UserDefaults.standard.object(forKey: "favourites") as? [Int] {
            favourites = savedFavourites
        }
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }
    
    func loadJSON() {
        guard let url = Bundle.main.url(forResource: "projects", withExtension: "json") else {
            fatalError("Unable to find JSON file")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON file")
        }
        let decoder = JSONDecoder()
        guard let projects = try? decoder.decode([Project].self, from: data) else {
            fatalError("Unable to decode JSON file")
        }
        
        self.projects = projects.sorted { $0.title < $1.title }
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
            NSAttributedString.Key.foregroundColor: UIColor.purple
        ]
        let subtitleAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)
        ]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        
        return titleString
    }
    
    func showTutorial(_ which: Int) {
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: project.title, subtitle: project.description)
        
        if favourites.contains(indexPath.row) {
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if favourites.contains(indexPath.row) {
            return .delete
        } else {
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Deselect"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .insert {
            favourites.append(indexPath.row)
            index(item: indexPath.row)
        } else {
            if let index = favourites.firstIndex(of: indexPath.row) {
                favourites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }

        UserDefaults.standard.set(favourites, forKey: "favourites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func index(item: Int) {
        let project = projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = project.title
        attributeSet.contentDescription = project.description
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed.")
            }
        }
    }
    
    func deindex(item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
}
