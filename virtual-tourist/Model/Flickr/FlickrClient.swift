//
//  FlickrClient.swift
//  virtual-tourist
//
//  Created by Frank Mortensen on 16/04/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import UIKit

class FlickrClient {
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        
        case search(Double, Double)
        
        var stringValue: String {
            
            switch self {
                case .search(let latitude, let longitude):
                
                    // I want this to crash magnificently if the FlickrApi file is missing
                    let path = Bundle.main.path(forResource: "FlickrApi", ofType: "plist")!
                    let dict = NSDictionary(contentsOfFile: path)!
                    let flickrApiKey = dict["FLICKR_API_KEY"] as! String
                    let randomPage = Int.random(in: 0...10)
                    
                    return Endpoints.base + "&api_key=\(flickrApiKey)&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1&extras=url_q&per_page=18&page=\(randomPage)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func searchImages(
        latitude: Double,
        longitude: Double,
        completion: @escaping (FlickrPhotos?, Bool, ErrorType?) -> Void
    ) {
        
        let request = URLRequest(url: Endpoints.search(latitude, longitude).url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, false, ErrorType.NetworkError)
                    }

                    return
                }

                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(SearchResponse.self, from: data)

                    DispatchQueue.main.async {
                        completion(responseObject.photos, true, nil)
                    }

                } catch {
                    DispatchQueue.main.async {
                        completion(nil, false, ErrorType.DecodeError)
                    }
                }}
            
            task.resume()
        
    }
    
    class func loadImage(
        photo: Photo,
        dataController: DataController
    ) {
        
        let downloadQueue = DispatchQueue(label: "download", attributes: [])
            
        downloadQueue.async { () -> Void in
            
            let url = photo.url
            photo.data = try! Data(contentsOf: url!)
                
            DispatchQueue.main.async(execute: { () -> Void in
                try! dataController.viewContext.save()
            })
        }
            
    }
}
