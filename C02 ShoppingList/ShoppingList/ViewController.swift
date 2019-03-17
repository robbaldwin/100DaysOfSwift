//
//  ViewController.swift
//  ShoppingList
//
//  Created by Rob Baldwin on 12/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class ViewController: UITableViewController {
    
    private var items: [String] = [] {
        didSet {
            UserDefaults.standard.setValue(items, forKey: "items")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        loadData()
    }
    
    private func setupNavigationBar() {
        title = "Shopping List"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteList))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareList))
        navigationItem.rightBarButtonItems = [addButton, shareButton]
    }
    
    private func loadData() {
        if let items = UserDefaults.standard.array(forKey: "items") as? [String] {
            self.items = items
        }
    }
    
    @objc
    private func addItem() {
        let ac = UIAlertController(title: "Add Item", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter item name"
            textField.autocapitalizationType = .sentences
            textField.font = UIFont.systemFont(ofSize: 20.0)
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak ac]_ in
            guard let item = ac?.textFields?[0].text else { return }
            self?.submitItem(item)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(addAction)
        ac.addAction(cancelAction)
        present(ac, animated: true, completion: nil)
    }
    
    private func submitItem(_ item: String) {
        if isDuplicate(item) {
            let ac = UIAlertController(title: "Duplicate!", message: "You already have that item in your list.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            insertItem(item)
        }
    }
    
    private func isDuplicate(_ item: String) -> Bool {
        return items.contains(item.lowercased())
    }
    
    private func insertItem(_ item: String) {
        items.append(item.lowercased())
        items = items.sorted { $0 < $1 }
        tableView.reloadData()
        
        print(items)
    }
    
    private func editItem(_ itemIndex: Int) {
        let ac = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        ac.addTextField { [weak self] (textField) in
            textField.placeholder = "Enter item name"
            textField.autocapitalizationType = .sentences
            textField.font = UIFont.systemFont(ofSize: 20.0)
            textField.text = self?.items[itemIndex].capitalized
        }
        ac.addAction(UIAlertAction(title: "Update", style: .default) { [weak self, weak ac]_ in
            guard let item = ac?.textFields?[0].text else { return }
            self?.items[itemIndex] = item.lowercased()
            let indexPath = IndexPath(row: itemIndex, section: 0)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc
    private func shareList() {
        var shoppingList: String = "My Shopping List\n\n"
        shoppingList.append("I need \(items.count) items from the shop.\n\n")
        for (index, item) in items.enumerated() {
            shoppingList.append("\(index + 1). \(item.capitalized)\n")
        }
        let activityVC = UIActivityViewController(activityItems: [shoppingList], applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems![1]
        present(activityVC, animated: true)
    }
    
    @objc
    private func deleteList() {
        let ac = UIAlertController(title: "Delete List?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.items.removeAll()
            self?.tableView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }

    // MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.capitalized
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        editItem(indexPath.row)
    }
}
