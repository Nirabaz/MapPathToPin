//
//  Constants.swift
//  MapPathToPin
//
//  Created by Mykhailo Zabarin on 10/11/18.
//  Copyright © 2018 Mykhailo Zabarin. All rights reserved.
//

import UIKit

typealias APIParams = [String: Any]?
typealias api_success_block = (_ success: Bool, _ object: APIParams, _ errMessage: String?) -> Void

let APP_DELEGATE  = UIApplication.shared.delegate as! AppDelegate
