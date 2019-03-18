//
//  ViewController.swift
//  NASA-Apod
//
//  Created by Rob Baldwin on 17/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit

final class ViewController: UICollectionViewController {

    var photos: [NASAPhoto] = []
    private var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureActivityIndicator()
        activityIndicator.startAnimating()
        performSelector(inBackground: #selector(fetchPhotos), with: nil)
    }
    
    private func configureActivityIndicator() {
        activityIndicator.sizeToFit()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    @objc
    private func fetchPhotos() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd"
        let toDate = dateFormatter.string(from: Date())
        guard let dateTwoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: Date()) else {
            fatalError("Unable to resolve fromDate")
        }
        let fromDate = dateFormatter.string(from: dateTwoWeeksAgo)
        
        let urlString = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&start_date=\(fromDate)&end_date=\(toDate)"
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {

                parse(jsonData: data)
                return
            }
        } else {
            print("Did not get Data")
        }
    }
    
    private func parse(jsonData: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPhotoData = try? decoder.decode([NASAPhoto].self, from: jsonData) {
            photos = jsonPhotoData.sorted { $0.date > $1.date }
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.collectionView.reloadData()
            }
        }
    }
    
    @objc
    private func showError() {
        let ac = UIAlertController(title: "Error", message: "There was a problem downloading the photos.  Please try again later", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? DetailViewController {
            if let indexPath = collectionView.indexPathsForSelectedItems?.first {
                    destinationVC.selectedPhoto = photos[indexPath.item]
            }
        }
    }
    
    // MARK: - Collection View DataSource & Delegate
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NASAPhotoCell", for: indexPath) as? NASAPhotoCell else {
            fatalError("Unable to dequeue a NASAPhotoCell")
        }
        
        let photo = photos[indexPath.item]
        
        cell.dateLabel.text = photo.date
        
        if let imageData = photo.imageData {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            let cellActivityView = UIActivityIndicatorView(style: .whiteLarge)
            cellActivityView.center = cell.imageView.center
            cell.imageView.addSubview(cellActivityView)
            cellActivityView.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let url = URL(string: photo.url) {
                    if let imageData = try? Data(contentsOf: url) {
                        DispatchQueue.main.async { [weak self] in
                            self?.photos[indexPath.item].imageData = imageData
                            cellActivityView.stopAnimating()
                            cellActivityView.removeFromSuperview()
                            cell.imageView.image = UIImage(data: imageData)
                        }
                    } else {
                        cellActivityView.stopAnimating()
                        self?.performSelector(onMainThread: #selector(self?.showError), with: nil, waitUntilDone: false)
                    }
                } else {
                    cellActivityView.stopAnimating()
                    self?.performSelector(onMainThread: #selector(self?.showError), with: nil, waitUntilDone: false)
                }
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPhoto", sender: self)
    }
}
