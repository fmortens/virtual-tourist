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
    var selectedObjectId: NSManagedObjectID?
    
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
        
        try? dataController.viewContext.save()
        
        addAnnotation(newMapPoint)
    }
    
    func initAnnotations() {
        if let mapPoints: [MapPoint] = fetchedResultsController.fetchedObjects {
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            var annotations = [AnnotationWithObjectId]()
            
            for mapPoint in mapPoints {
                let annotation = AnnotationWithObjectId()
                
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: Double(mapPoint.latitude),
                    longitude: Double(mapPoint.longitude)
                )
                
                annotation.objectId = mapPoint.objectID
                
                annotations.append(annotation)
            }
            
            if annotations.count > 0 {
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    func addAnnotation(_ mapPoint: MapPoint) {
        let annotation = AnnotationWithObjectId()
        
        annotation.objectId = mapPoint.objectID
        
        annotation.coordinate = CLLocationCoordinate2D(
            latitude: Double(mapPoint.latitude),
            longitude: Double(mapPoint.longitude)
        )
        
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let selectedAnnotation = view.annotation {
            let customAnnotation = selectedAnnotation.self as! AnnotationWithObjectId
            
            // find mapPoint with the matching coordinates and pass it via segue to the album view
            print("Map annotation was selected! \(String(describing: customAnnotation.objectId))")
            
            selectedObjectId = customAnnotation.objectId
            
            self.performSegue(withIdentifier: "openAlbumModal", sender: self)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedObjectId = nil
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is AlbumModalViewController {
            let viewController = segue.destination as? AlbumModalViewController
            viewController?.objectId = selectedObjectId
        }
        
    }
    
}

class AnnotationWithObjectId: MKPointAnnotation {
    
    var objectId: NSManagedObjectID?
    
}
