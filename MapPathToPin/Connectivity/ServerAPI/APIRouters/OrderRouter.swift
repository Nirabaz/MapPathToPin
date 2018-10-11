//
//  orderRouter.swift
//  MapPathToPin
//
//  Created by Mykhailo Zabarin on 10/11/18.
//  Copyright © 2018 Mykhailo Zabarin. All rights reserved.
//

import Foundation

import Foundation
import Alamofire

enum OrderEndpoint {
    case GetOrderByCoordinates(Double, Double, APIParams)
}

class OrderRouter: BaseRouter {
    
    private var endpoint: OrderEndpoint
    
    init(anEndpoint: OrderEndpoint) {
        endpoint = anEndpoint
    }
    
    override var method: HTTPMethod {
        switch endpoint {
        case .GetOrderByCoordinates(_):
            return .get
        }
    }
    
    override var path: String {
        switch endpoint {
        case .GetOrderByCoordinates(let lat, let lon, _):
            var urlComponents = URLComponents(string: "")!
            urlComponents.queryItems = [
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "lat", value: "\(lat)"),
                URLQueryItem(name: "lon", value: "\(lon)")
            ]
            
            let url = urlComponents.url!
            return url.absoluteString
            
        }
    }
    
    override var parameters: APIParams {
        switch endpoint {
        case .GetOrderByCoordinates(_, _, let params):
            return params
        }
    }
    
    override var encoding: ParameterEncoding? {
        switch endpoint {
        case .GetOrderByCoordinates:
            return JSONEncoding.default
        }
    }
}
