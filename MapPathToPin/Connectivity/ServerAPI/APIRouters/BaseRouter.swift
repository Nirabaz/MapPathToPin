//
//  BaseRouter.swift
//  MapPathToPin
//
//  Created by Mykhailo Zabarin on 10/11/18.
//  Copyright © 2018 Mykhailo Zabarin. All rights reserved.
//

import Foundation
import Alamofire



let kServerBaseURL = "https://nominatim.openstreetmap.org/reverse.php"

// MARK: - Router
protocol RouterProtocol {
    var method: Alamofire.HTTPMethod { get }
    var parameters: APIParams {get}
    var path: String { get }
    var baseUrl: String { get }
    var encoding: Alamofire.ParameterEncoding? { get }
    
}

class BaseRouter: RouterProtocol, URLRequestConvertible {
    
    init() {}
    
    var method: HTTPMethod {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var parameters: APIParams {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var path: String {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var encoding: ParameterEncoding? {
        fatalError("[\(self) - \(#function))] Must be overridden in subclass")
    }
    
    var baseUrl: String {
        return kServerBaseURL
    }
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = NSURL(string: baseUrl)
        let mutableURLRequest = NSMutableURLRequest(url: (baseURL?.appendingPathComponent(path))!)
        mutableURLRequest.httpMethod = method.rawValue
        
        if let encoding = encoding {
            return try encoding.encode(mutableURLRequest as URLRequest, with: parameters)
        }
        
        return mutableURLRequest as URLRequest
    }
    
}

