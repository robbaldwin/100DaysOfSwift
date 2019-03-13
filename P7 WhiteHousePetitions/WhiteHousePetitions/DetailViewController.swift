//
//  DetailViewController.swift
//  WhiteHousePetitions
//
//  Created by Rob Baldwin on 13/03/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {

    private var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        loadHTML()
    }
    
    private func loadHTML() {
        guard let detailItem = detailItem else { return }
        
        title = detailItem.id
        
        var issues: String = ""
        
        for issue in detailItem.issues {
            issues.append("\(issue.name)<br>")
        }
        
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-family: Arial; font-size: 120%; } </style>
        </head>
        <body>
        <h3><b>\(detailItem.title)</b></h3>
        <b>Issues</b><br>
        \(issues)<br>
        <i>\(detailItem.body)</i><br><br>
        <b>Status: \(detailItem.status)</b><br><br>
        Signatures: \(detailItem.signatureCount)<br>
        Signatures Required: \(detailItem.signatureThreshold)<br>
        Signatures still needed: \(detailItem.signaturesNeeded)<br>
        Date created: \(date(from: detailItem.created))<br>
        Deadline: \(date(from: detailItem.deadline))<br><br>
        <a href="\(detailItem.url)">Link to Petition</a>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func date(from timeInterval: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = Date(timeIntervalSince1970: timeInterval)
        return dateFormatter.string(from: date)
    }
}
