//
//  ViewController.swift
//  SelfieShare
//
//  Created by Rob Baldwin on 25/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import MultipeerConnectivity
import UIKit

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var images: [UIImage] = []
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Selfie Share"
        
        // Challenge 3: Add a button that shows an alert controller listing the names of all devices currently connected to the session – use the connectedPeers property of your session to find that information.
        
        // More than one UIBarButton (per side) need to be added as array of [UIBarButtonItem]
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showConnectedPeers))
        ]
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture)),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeTextMessage))
        ]

        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-SelfieShare", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "hws-SelfieShare", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    // Challenge 3: Add a button that shows an alert controller listing the names of all devices currently connected to the session – use the connectedPeers property of your session to find that information.
    @objc func showConnectedPeers() {
        guard let mcSession = mcSession else { return }

        let peers = mcSession.connectedPeers.map { $0.displayName }
        
        let ac = UIAlertController(title: "Connected Peers", message: "\(peers.joined(separator: "\n"))", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    // Challenge 2: Try sending text messages across the network. You can create a Data from a string using Data(yourString.utf8), and convert a Data back to a string by using String(decoding: yourData, as: UTF8.self).
    
    @objc func composeTextMessage() {
        let ac = UIAlertController(title: "Send Text Message", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            textField.placeholder = "Enter Message"
            textField.autocapitalizationType = .sentences
            textField.font = UIFont.systemFont(ofSize: 20)
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak ac, weak self] _ in
            guard let message = ac?.textFields?[0].text else { return }
            self?.sendTextMessage(message)
        }))
        present(ac, animated: true)
    }
    
    func sendTextMessage(_ message: String) {
        guard let mcSession = mcSession else { return }
    
        // Check if there are any peers to send to.
        if mcSession.connectedPeers.count > 0 {
            // Convert message to Data
            let messageData = Data(message.utf8)
            do {
                try mcSession.send(messageData, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                // Show an error message if there's a problem.
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        // Check if we have an active session we can use.
        guard let mcSession = mcSession else { return }
        
        // Check if there are any peers to send to.
        if mcSession.connectedPeers.count > 0 {
            // Convert the new image to a Data object.
            if let imageData = image.pngData() {
                // Send it to all peers, ensuring it gets delivered.
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    // Show an error message if there's a problem.
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            
            // Challenge 1: Show an alert when a user has disconnected from our multipeer network. Something like “Paul’s iPhone has disconnected” is enough.
            let ac = UIAlertController(title: "\(peerID.displayName) has disconnected", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

        // Check if received data is a UIImage
        if let image = UIImage(data: data) {
            DispatchQueue.main.async { [weak self] in
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            }
        } else {
            // Challenge 2: Try sending text messages across the network. You can create a Data from a string using Data(yourString.utf8), and convert a Data back to a string by using String(decoding: yourData, as: UTF8.self).
            let message = String(decoding: data, as: UTF8.self)
            DispatchQueue.main.async { [weak self] in
                let ac = UIAlertController(title: "Message from \(peerID.displayName)", message: message, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(ac, animated: true)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // not used
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // not used
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // not used
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
