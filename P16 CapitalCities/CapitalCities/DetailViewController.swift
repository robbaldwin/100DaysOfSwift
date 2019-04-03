//
//  DetailViewController.swift
//  CapitalCities
//
//  Created by Rob Baldwin on 02/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit
import WebKit

final class DetailViewController: UIViewController {
    
    private var webView: WKWebView!
    
    var city: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = city
        webView = WKWebView()
        view = webView
        loadWiki()
    }
    
    private func loadWiki() {
        guard
            let city = city,
            let url = URL(string: "https://en.wikipedia.org/wiki/\(city)") else { return }
        webView.load(URLRequest(url: url))
    }
}
