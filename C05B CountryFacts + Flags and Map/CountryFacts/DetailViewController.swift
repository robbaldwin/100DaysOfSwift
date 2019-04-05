//
//  DetailViewController.swift
//  CountryFacts
//
//  Created by Rob Baldwin on 01/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import MapKit
import UIKit
import WebKit

final class DetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var webView: WKWebView!

    var country: Country!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        title = country.name
        
        loadFlag()
        loadMap()
        webView.loadHTMLString(HTMLString(), baseURL: nil)
    }
    
    func loadFlag() {
        imageView.layer.borderColor = UIColor.darkGray.cgColor
        imageView.layer.borderWidth = 1
        imageView.image = UIImage(named: country.alpha2Code.lowercased())
    }

    func loadMap() {
        guard
            let latitude = country.latlng.first,
            let longitude = country.latlng.last
            else { return }

        let centreCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Set Annotation
        let annotation = CountryAnnotation(name: country.name, coordinate: centreCoordinates )
        mapView.addAnnotation(annotation)
        
        // Centre map on location
        let region = MKCoordinateRegion(
            center: centreCoordinates,
            latitudinalMeters: 3_000_000,
            longitudinalMeters: 3_000_000)
        mapView.setRegion(region, animated: true)
    }
    
    func HTMLString() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let area = numberFormatter.string(from: NSNumber(value: country.area ?? 0))
        let population = numberFormatter.string(from: NSNumber(value: country.population))
        
        var html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        body { font-family: Arial; font-size: 100%; }
        </style>
        </head>
        <body>
        Capital: <b>\(country.capital)</b><br>
        Region: <b>\(country.region)</b><br>
        SubRegion: <b>\(country.subregion)</b><br>
        """
        
        html.append("Blocs: ")
        for bloc in country.regionalBlocs {
            html.append("<b>\(bloc.name)</b>, ")
        }
        
        html.append("<br>Location: ")
        for latlng in country.latlng {
            html.append("<b>\(latlng)</b>, ")
        }

        html.append("""
            <br>
            Population: <b>\(population ?? "Unknown")</b><br>
            Area: <b>\(area ?? "Unknown") km2</b><br>
            Demonym: <b>\(country.demonym)</b>
        """)

        html.append("<br>Languages: ")
        for language in country.languages {
            html.append("<b>\(language.name)</b>, ")
        }
        
        html.append("<br>Domains: ")
        for domain in country.topLevelDomain {
            html.append("<b>\(domain)</b>, ")
        }
        
        html.append("<br>Currencies: ")
        let currencies = country.currencies.compactMap { $0.name }
        for currency in currencies {
            html.append("<b>\(currency)</b>, ")
        }
        
        html.append("<br>Calling Codes: ")
        for code in country.callingCodes {
            html.append("<b>\(code)</b>, ")
        }
        
        html.append("<br>Time Zones: ")
        for zone in country.timezones {
            html.append("<b>\(zone)</b>, ")
        }

        html.append("</body></html>")
        
        return html
    }

    @objc
    func shareButtonTapped() {
        var html = "<h2>\(country.name)</h2>"
        html += HTMLString()
        
        let activityVC = UIActivityViewController(activityItems: [html], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
}
