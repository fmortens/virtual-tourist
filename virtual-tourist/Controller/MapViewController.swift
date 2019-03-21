//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by Frank Mortensen on 21/03/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(MapViewController.longpress(gestureRecognizer:))
        )
        
        longPressRecognizer.minimumPressDuration = 2
        
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
        print("coordinate \(coordinate)")
    }
    
}

