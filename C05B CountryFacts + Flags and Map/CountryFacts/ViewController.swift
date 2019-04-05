//
//  ViewController.swift
//  CountryFacts
//
//  Created by Rob Baldwin on 01/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class ViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var countries: [Country] = []
    var filteredCountries: [Country] = []
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Country Facts"
        configureSearchController()
        loadCountries()
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        navigationItem.searchController = searchController
        self.definesPresentationContext = true
    }
    
    func loadCountries() {
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
        filterSearchResults()
    }
    
    func filterSearchResults() {
        guard let searchBarText = searchController.searchBar.text?.lowercased() else { return }
        
        if searchBarText.isEmpty {
            self.filteredCountries = countries
        } else {
            self.filteredCountries = countries.filter {
                $0.name.lowercased().contains(searchBarText)
            }
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        let country = filteredCountries[indexPath.row]
        cell.imageView?.image = UIImage(named: country.alpha2Code.lowercased())
        cell.imageView?.layer.borderWidth = 0.5
        cell.textLabel?.text = country.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
            fatalError("Unable to instantiate DetailViewController")
        }
        vc.country = filteredCountries[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearchResults()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterSearchResults()
    }
}
