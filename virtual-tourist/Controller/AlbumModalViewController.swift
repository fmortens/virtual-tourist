//
//  AlbumModalViewController.swift
//  virtual-tourist
//
//  Created by Frank Mortensen on 07/04/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AlbumModalViewController: UIViewController {
    
    @IBOutlet weak var mapImage: UIImageView!
    
    var dataController: DataController!
    var selectedMapPoint: MapPoint?
    
    override func viewDidLoad() {
        
        if let selectedMapPoint = self.selectedMapPoint {
            createMapSnapshot(mapPoint: selectedMapPoint)
        }
        
    }
    
    func createMapSnapshot(mapPoint: MapPoint) {
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        let location = CLLocationCoordinate2DMake(
            CLLocationDegrees(mapPoint.latitude),
            CLLocationDegrees(mapPoint.longitude)
        )
        
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        mapSnapshotOptions.region = region
        
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        mapSnapshotOptions.size = CGSize(width: 300, height: 300)
        
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapShotter.start {
            (snapshot:MKMapSnapshotter.Snapshot?, error:Error?) in
                self.mapImage.image = snapshot?.image
        }
        
    }
    
    @IBAction func dismissModal(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
