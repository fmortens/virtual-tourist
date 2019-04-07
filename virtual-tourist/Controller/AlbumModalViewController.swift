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
    
    var objectId: NSManagedObjectID?
    
    override func viewDidLoad() {
        print("OK, we have a modal and we want to look at: \(String(describing: objectId))")
    }
    
}
