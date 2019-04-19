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

class AlbumModalViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var noPhotosText: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataController: DataController!
    var mapPoint: MapPoint!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var photosToDelete = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        noPhotosText.isHidden = true
        
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        
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
                if mapPoint.photos?.count == 0 {
                    noPhotosText.isHidden = false
                }
            } else {
                noPhotosText.isHidden = true
                FlickrClient.searchImages(
                    latitude: Double(mapPoint.latitude),
                    longitude: Double(mapPoint.longitude),
                    completion: handleSearchImages
                )
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "mapPoint == %@", mapPoint)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(
            key: "creationDate",
            ascending: false
        )
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: dataController.viewContext,
            sectionNameKeyPath: nil,
            cacheName: "\(mapPoint.objectID)-photos"
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func handleSearchImages(searchResults: FlickrPhotos?, success: Bool, error: ErrorType?) {
        
        if let photos = searchResults?.photo {
            
            if photos.count == 0 {
                noPhotosText.isHidden = false
            } else {
                noPhotosText.isHidden = true
                for flickPhoto: FlickrPhoto in photos {
                    let photo = Photo(context: dataController.viewContext)
                
                    photo.url = URL(string: flickPhoto.url)
                    photo.mapPoint = mapPoint
                    photo.creationDate = Date()
                
                    try? dataController.viewContext.save()
                
                    // Start load the actual images
                    FlickrClient.loadImage(
                        photo: photo,
                        dataController: dataController,
                        completion: handleLoadImage
                    )
                }
            }
        }
        
        mapPoint.photosLoaded = true
        try? dataController.viewContext.save()
        
    }
    
    func handleLoadImage(success: Bool, error: ErrorType?) {
        // I thought I could show friendly error messages to the user here
        if success {
            //print("Image loaded successfully")
        } else {
            //print("Image failed to load")
        }
        
    }
    
    @IBAction func deleteMapPoint(_ sender: Any) {
        
        if let mapPoint = self.mapPoint {
            dataController.viewContext.delete(mapPoint)
            try? dataController.viewContext.save()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func loadNewCollection(_ sender: Any) {
        
        if let mapPoint = self.mapPoint,
           let photos = mapPoint.photos {
            
            mapPoint.photosLoaded = false
            
            for photo in photos {
                dataController.viewContext.delete(photo as! NSManagedObject)
                try? dataController.viewContext.save()
            }
            
            FlickrClient.searchImages(
                latitude: Double(mapPoint.latitude),
                longitude: Double(mapPoint.longitude),
                completion: handleSearchImages
            )
            
        }
        
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
        
        for photo in photosToDelete {
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
        
    }
}

extension AlbumModalViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photos = mapPoint.photos {
            return photos.count
        } else {
            return 0
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoCell",
            for: indexPath
            ) as! PhotoCell
        
        if let imageData = photo.data {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            cell.imageView.image = UIImage(named: "loadingImage")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 3.0
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.opacity = 0.5
            let photo = fetchedResultsController.object(at: indexPath)
            photosToDelete.append(photo)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.opacity = 1
            
            let photo = fetchedResultsController.object(at: indexPath)
            if let index = photosToDelete.index(of: photo) {
                photosToDelete.remove(at: index)
            }
            
        }
        
    }
    
}

extension AlbumModalViewController: NSFetchedResultsControllerDelegate {
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            noPhotosText.isHidden = true
            
        case .delete:
            
            if mapPoint.photos!.count == 0 {
                noPhotosText.isHidden = false
                collectionView.reloadData()
            } else {
                collectionView.deleteItems(at: [indexPath!])
            }
            
        case .update:
            collectionView.reloadItems(at: [indexPath!])
            
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        }
    }
    
}
