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
                    
                    return Endpoints.base + "&api_key=\(flickrApiKey)&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1&extras=url_q"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func searchImages(
        latitude: Double,
        longitude: Double,
        completion: @escaping (Photos?, Bool, ErrorType?) -> Void
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
        url: String,
        completion: @escaping (UIImage?, Bool, ErrorType?) -> Void
    ) {
        do {
            let url = URL(string: url)!
            let imgData = try Data(contentsOf: url)
            let image = UIImage(data: imgData)
            completion(image, true, nil)
        } catch {
            completion(nil, false, ErrorType.NetworkError)
        }
    }
}
