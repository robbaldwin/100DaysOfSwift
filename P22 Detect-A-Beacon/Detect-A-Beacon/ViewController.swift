//
//  ViewController.swift
//  Detect-A-Beacon
//
//  Created by Rob Baldwin on 17/04/2019.
//  Copyright © 2019 Rob Baldwin. All rights reserved.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var identifier: UILabel!
    @IBOutlet var distanceReading: UILabel!
    @IBOutlet var circleImageView: UIImageView!
    
    var locationManager: CLLocationManager?
    
    // Dictionary of multiple Beacons from the 'Locate' App
    let beacons: [UUID: String] = [
        UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!: "Apple Beacon 1",
        UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!: "Apple Beacon 2",
        UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!: "Apple Beacon 3"
    ]
    var activeBeaconUUID: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        identifier.text = "Not in Range"
        circleImageView.image = nil
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {

        // Challenge 2: Go through two or three other iBeacons in the Detect Beacon app and add their UUIDs to your app, then register all of them with iOS. Now add a second label to the app that shows new text depending on which beacon was located.
        
        // Iterate over the beacons dictionary, adding each one to the active monitoring
        for (uuid, identifier) in beacons {
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: identifier)
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(in: beaconRegion)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

        // Warning! Out of range or disabled beacons will still be returned active for about 10 seconds, with an 'unknown' distance, before they are finally removed from the beacons array!  Because of this the 'else' statement can be removed, as setting unknown will still be called in update().
        
        if let beacon = beacons.first {
            update(distance: beacon.proximity)

            // Challenge 1: Write code that shows a UIAlertController when your beacon is first detected.
            if activeBeaconUUID != beacon.proximityUUID {
                activeBeaconUUID = beacon.proximityUUID
                identifier.text = self.beacons[activeBeaconUUID!]
                showAlert(beacon: beacon)
            }
        }
    }
    
    func showAlert(beacon: CLBeacon) {
        
        let ac = UIAlertController(title: "Detected Beacon", message:
            """
            Identifier: \(beacons[beacon.proximityUUID] ?? "No Identifier")\n
            UUID: \(beacon.proximityUUID)
            """,
            preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func update(distance: CLProximity) {
        
        switch distance {
        case .far:
            self.distanceReading.text = "Far"
            self.circleImageView.image = UIImage(named: "blueCircle")
            animateCircle(scale: 0.5)
            
        case .near:
            self.distanceReading.text = "Near"
            self.circleImageView.image = UIImage(named: "orangeCircle")
            animateCircle(scale: 0.75)
            
        case .immediate:
            self.distanceReading.text = "Right Here"
            self.circleImageView.image = UIImage(named: "redCircle")
            animateCircle(scale: 1.0)
            
        default:
            self.identifier.text = "Not in Range"
            self.distanceReading.text = "Unknown"
            self.distanceReading.transform = .identity
            self.circleImageView.image = nil
        }
    }
    
    // Challange 3: Add a circle to your view, then use animation to scale it up and down depending on the distance from the beacon
    func animateCircle(scale: CGFloat) {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5.0, options: [], animations: {
            self.distanceReading.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.circleImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
}
