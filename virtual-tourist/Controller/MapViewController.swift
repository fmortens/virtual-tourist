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
    
//    var annotations = [MKPointAnnotation]()
//    var mapPoints = [MapPoint]()
    
   
    
    @IBOutlet weak var mapView: MKMapView!
    
    // Core data controllers
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
        
        //        let defaults = UserDefaults.standardUserDefaults()
        //
        //        if let latitude
        
        
        
//        loadUserDefaults()
        
        updatePins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Super important to set up the controller in both viewDidLoad and viewWillAppear, otherwise it will crash when returning here after opening a notebook
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
        
        //NSFetchedResultsController<Notebook>.deleteCache(withName: "notebooks")
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil,
            cacheName: "mapPoints"
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
            
            
                updatePins()
            
            
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
        
//        mapPoints.append(
//            MapPoint(title: "Blubb 1", coordinate: CLLocationCoordinate2D(latitude: 61.0, longitude: 10.0), subtitle: "wuhu")
//        )
    }
//    func loadUserDefaults() {
//
//        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//            print("\(key) = \(value) \n")
//        }
//
////        if let archivedSpan = UserDefaults.standard.object(forKey: "archivedSpan") as? MKCoordinateSpan {
////
//////            self.mapView.setRegion(MKCoordinateRegion, animated: <#T##Bool#>)
//////            self.mapView.setCenter(centerCoordinate, animated: true)
////            print("GOT DATA!!! \(archivedSpan)")
////        }
//
//
////            let mapCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
////            let mapSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
////
////            self.mapView.setCenter(mapCenter, animated: true)
////            self.mapView.setRegion(MKCoordinateRegion(center: mapCenter, span: mapSpan), animated: true)
//
//    }
    
    func updatePins() {
        
        if let mapPoints: [MapPoint] = fetchedResultsController.fetchedObjects {
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            var annotations = [MKPointAnnotation]()
            
            for mapPoint in mapPoints {
                
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: Double(mapPoint.latitude), longitude: Double(mapPoint.longitude))
                annotation.title = mapPoint.title
                annotation.subtitle = mapPoint.subtitle
                
                annotations.append(annotation)

            }
            
            if annotations.count > 0 {
                self.mapView.addAnnotations(annotations)
            }
        }
        
//        var annotations = [MKPointAnnotation]()
        
//        for mapPoint in self.dataController.viewContext.
//        for mapPoint in mapPoints {
//
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = mapPoint.coordinate
//            annotation.title = mapPoint.title
//            annotation.subtitle = mapPoint.subtitle
//
//            annotations.append(annotation)
//
//        }
//
//        self.mapView.addAnnotations(annotations)
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        
        addMapPoint(touchPoint)
        
        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//
//        annotations.append(annotation)
//
//        self.mapView.addAnnotations(annotations)
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    //    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    //        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
    //        if (mapChangedFromUserInteraction) {
    //            // user changed map region
    //        }
    //    }
    //
    //    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    //        if mapChangedFromUserInteraction {
    //            saveMapState()
    //        }
    //    }
    //
    //    func saveMapState() {
    //        let currentMapCoordinate = self.mapView.centerCoordinate
    //        let currentRegion = self.mapView.region
    //
    //        UserDefaults.standard.set(["latitude": currentMapCoordinate.latitude, "longitude": currentMapCoordinate.longitude], forKey: "coordinate")
    //        UserDefaults.standard.set(["latitude": currentRegion.center.latitude, "longitude": currentRegion.center.longitude, "self": currentRegion.self, "region": currentRegion.span], forKey: "scaling")
    //        UserDefaults.standard.synchronize()
    //    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        let defaults = UserDefaults.standard
//
////        defaults.set(self.mapView.centerCoordinate, forKey: "centerCoordinate")
//
//        let archivedSpan = try! NSKeyedArchiver.archivedData(withRootObject: self.mapView.region.span, requiringSecureCoding: false)
//        defaults.set(archivedSpan, forKey: "archivedSpan")
//        defaults.synchronize()
//    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
        ) {
        // fill map
    }
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
        ) {
        // fill map?
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
        ) {
        switch type {
        case .insert:
            print("insert map point") //tableView.insertRows(at: [newIndexPath!], with: .fade)
            updatePins()
        case .delete: //tableView.deleteRows(at: [indexPath!], with: .fade)
            print("deleting map point")
            updatePins()
        case .update, .move: fatalError(
            "Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible."
            )
        }
    }
}
