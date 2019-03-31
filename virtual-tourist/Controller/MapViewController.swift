//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by Frank Mortensen on 21/03/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<MapPoint>!
    
    private var mapChangedFromUserInteraction = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        setUpFetchedResultsController()
        
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(MapViewController.longpress(gestureRecognizer:))
        )
        
        // I declare a longpress when it has been pressed for 1 second
        longPressRecognizer.minimumPressDuration = 1
        
        mapView.addGestureRecognizer(longPressRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<MapPoint> = MapPoint.fetchRequest()
        let sortDescriptor = NSSortDescriptor(
            key: "creationDate",
            ascending: false
        )
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil,
            cacheName: "mapPoints"
        )
        
        do {
            try fetchedResultsController.performFetch()
            
            initAnnotations()
        } catch {
            fatalError("The fetch could not be performed \(error.localizedDescription)")
        }
    }
    
    func addMapPoint(_ touchPoint: CGPoint) {
        
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
        let newMapPoint = MapPoint(context: dataController.viewContext)
        newMapPoint.creationDate = Date()
        newMapPoint.latitude = Float(coordinate.latitude)
        newMapPoint.longitude = Float(coordinate.longitude)
        newMapPoint.title = "New location"
        newMapPoint.subtitle = "A brand new point"
        
        try? dataController.viewContext.save()
        
        addAnnotation(newMapPoint)
    }
    
    func initAnnotations() {
        if let mapPoints: [MapPoint] = fetchedResultsController.fetchedObjects {
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            var annotations = [MKPointAnnotation]()
            
            for mapPoint in mapPoints {
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: Double(mapPoint.latitude),
                    longitude: Double(mapPoint.longitude)
                )
                
                annotation.title = mapPoint.title
                annotation.subtitle = mapPoint.subtitle
                
                annotations.append(annotation)
            }
            
            if annotations.count > 0 {
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    func addAnnotation(_ mapPoint: MapPoint) {
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: Double(mapPoint.latitude),
            longitude: Double(mapPoint.longitude)
        )
        
        annotation.title = mapPoint.title
        annotation.subtitle = mapPoint.subtitle
        
        self.mapView.addAnnotation(annotation)
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        
        addMapPoint(touchPoint)
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        
        return false
    }
}
