//
//  SearchResult.swift
//  virtual-tourist
//
//  Created by Frank Mortensen on 16/04/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case farm
        case title
        case ispublic
        case isfriend
        case isfamily
        case url = "url_q"
    }
}
