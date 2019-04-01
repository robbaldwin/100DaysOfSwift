//
//  DetailViewController.swift
//  CountryFacts
//
//  Created by Rob Baldwin on 01/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit
import WebKit

final class DetailViewController: UIViewController {

    private var webView: WKWebView!
    
    var country: Country!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        title = "Country Facts"
        
        webView = WKWebView()
        view = webView
        webView.loadHTMLString(HTMLString(), baseURL: nil)
    }
    
    private func HTMLString() -> String {
        
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
        <h1>\(country.name)</h1>
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
        
        html.append("""
            <br><h2>Translations: </h2>
            German: <b>\(country.translations.de ?? "")</b><br>
            Spanish: <b>\(country.translations.es ?? "")</b><br>
            French: <b>\(country.translations.fr ?? "")</b><br>
            Japanese: <b>\(country.translations.ja ?? "")</b><br>
            Italian: <b>\(country.translations.it ?? "")</b><br>
            Breton: <b>\(country.translations.br ?? "")</b><br>
            Portuguese: <b>\(country.translations.pt ?? "")</b><br>
            Dutch: <b>\(country.translations.nl ?? "")</b><br>
            Croation: <b>\(country.translations.hr ?? "")</b><br>
            Persian: <b>\(country.translations.fa ?? "")</b><br>
            """)
        
        html.append("</body></html>")
        
        return html
    }

    @objc
    private func shareButtonTapped() {
        let activityVC = UIActivityViewController(activityItems: [HTMLString()], applicationActivities: [])
        present(activityVC, animated: true, completion: nil)
    }
}
