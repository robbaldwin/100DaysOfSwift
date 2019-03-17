//
//  ViewController.swift
//  World Flags
//
//  Created by Rob Baldwin on 07/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var countries: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "World Flags"
        tableView.rowHeight = 70.0
        loadJSON()
    }
    
    private func loadJSON() {
        guard let url = Bundle.main.url(forResource: "Countries", withExtension: "json") else {
            fatalError("Unable to find JSON file")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON file")
        }
        let decoder = JSONDecoder()
        guard let countries = try? decoder.decode([Country].self, from: data) else {
            fatalError("Unable to decode JSON file")
        }
        self.countries = countries.sorted { $0.name < $1.name }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath) as? CountryCell else {
            fatalError("Unable to dequeue cell")
        }
        let country = countries[indexPath.row]
        cell.imageView?.image = UIImage(named: country.code.lowercased())
        cell.countryLabel.text = country.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            fatalError("Unable to instantiate DetailViewController")
        }
        vc.selectedCountry = countries[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

