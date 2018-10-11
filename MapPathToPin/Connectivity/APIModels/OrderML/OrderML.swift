//
//  OrderML.swift
//  MapPathToPin
//
//  Created by Mykhailo Zabarin on 10/11/18.
//  Copyright © 2018 Mykhailo Zabarin. All rights reserved.
//

import Foundation

enum OrderMLKeys: String, CodingKey {
    case id = "place_id"
    case latitude = "lat"
    case longitude = "lon"
    case displayName = "display_name"
}

final class OrderML: DecodableFromParams {
    
    private var _id : String!
    private var _latitude: String!
    private var _longitude: String!
    private var _displayName: String!
    
    var id: String {
        get {
            return _id
        }
    }
    
    var latitude: String {
        get {
            return _latitude
        }
    }
    
    var longitude: String {
        get {
            return _longitude
        }
    }
    
    var displayName: String {
        get {
            return _displayName
        }
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: OrderMLKeys.self)
        
        _id = try container.decode(String.self, forKey: .id)
        _latitude = try container.decode(String.self, forKey: .latitude)
        _longitude = try container.decode(String.self, forKey: .longitude)
        _displayName = try container.decode(String.self, forKey: .displayName)
    }
}
