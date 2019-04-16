//
//  FlickrClient.swift
//  virtual-tourist
//
//  Created by Frank Mortensen on 16/04/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation

class FlickrClient {
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        
        case search(String, Double, Double)
        
        var stringValue: String {
            
            switch self {
            case .search(let apiKey, let latitude, let longitude):
                return Endpoints.base + "&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func loadImages(latitude: Double, longitude: Double, completion: @escaping (Photos?, Bool, ErrorType?) -> Void) {
        
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "FlickrApi", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let flickrApiKey = dict["FLICKR_API_KEY"] as? String
            
            let request = URLRequest(url: Endpoints.search(flickrApiKey!, latitude, longitude).url)
            
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
    }
}
