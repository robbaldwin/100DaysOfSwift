//
//  ViewController.swift
//  StormViewer
//
//  Created by Rob Baldwin on 07/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        loadItems()
    }
    
    private func loadItems() {
        
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath else {
            fatalError("Unable to locate resourcePath")
        }
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path)
            for item in items  {
                if item.hasPrefix("nssl") {
                    pictures.append(item)
                }
            }
            print(pictures)
            pictures = pictures.sorted { $0 < $1 }
            print(pictures)
        } catch let error {
            print("Unable to get items from directory: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let picture = pictures[indexPath.row]
        cell.textLabel?.text = picture
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            fatalError("Unable to instantiate DetailViewController")
        }
        
        let selectedPicture = pictures[indexPath.row]
        if let indexOfPicture = pictures.firstIndex(of: selectedPicture) {
            let pictureTitle = "Picture \(indexOfPicture + 1) of \(pictures.count)"
            vc.pictureTitle = pictureTitle
        }
        vc.selectedPicture = pictures[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

