//
//  Errors.swift
//  virtual-tourist
//
//  Created by Frank Mortensen on 16/04/2019.
//  Copyright © 2019 Frank Mortensen. All rights reserved.
//

import Foundation

enum ErrorType: String {
    case NetworkError = "A network error occurred"
    case DecodeError = "Could not decode response from Flickr"
}
