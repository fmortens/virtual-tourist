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
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var mapPoint: MapPoint?
    var selectedObjectId: NSManagedObjectID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        if let objectId = selectedObjectId {
            mapPoint = (dataController.viewContext.object(
                with: objectId
            ) as! MapPoint)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let annotation = MKPointAnnotation()
        
        if let mapPoint = self.mapPoint {
            annotation.coordinate = CLLocationCoordinate2D(
                latitude: Double(mapPoint.latitude),
                longitude: Double(mapPoint.longitude)
            )
        
            mapView.addAnnotation(annotation)
        
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: Double(mapPoint.latitude),
                    longitude: Double(mapPoint.longitude)
                ),
                latitudinalMeters: CLLocationDistance(exactly: 10000)!,
                longitudinalMeters: CLLocationDistance(exactly: 10000)!
            )
        
            mapView.setRegion(
                mapView.regionThatFits(region),
                animated: true
            )
            
            if mapPoint.photosLoaded {
        
            print("number of stored photos: \(String(describing: mapPoint.photos?.count))")
            } else {
            FlickrClient.searchImages(
                latitude: Double(mapPoint.latitude),
                longitude: Double(mapPoint.longitude),
                completion: handleSearchImages
            )
            }
        }
    }
    
    func handleSearchImages(photos: FlickrPhotos?, success: Bool, error: ErrorType?) {
        
        if let photos = photos?.photo {
            for photo: FlickrPhoto in photos {
                FlickrClient.loadImage(url: photo.url, completion: handleLoadImage)
            }
        }
        
        mapPoint?.photosLoaded = true
        try? dataController.viewContext.save()
        
    }
    
    func handleLoadImage(imageData: Data?, success: Bool, error: ErrorType?) {
        if success {
            let photo = Photo(context: dataController.viewContext)
            photo.data = imageData
            photo.mapPoint = mapPoint
            try? dataController.viewContext.save()
        }
    }
    
    @IBAction func deleteMapPoint(_ sender: Any) {
        
        if let mapPoint = self.mapPoint {
            dataController.viewContext.delete(mapPoint)
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}
