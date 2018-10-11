//
//  NetworkManager.swift
//  MapPathToPin
//
//  Created by Mykhailo Zabarin on 10/11/18.
//  Copyright © 2018 Mykhailo Zabarin. All rights reserved.
//


import UIKit
import Reachability

class NetworkManager: NSObject {
    
    static let sharedManager = NetworkManager()
    private let reachability = Reachability()!
    
    private override init() {
        super.init()
        observeInternetConnection()
    }
    
    private func observeInternetConnection() {
        // Internet is reachable
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        
        // Internet is not reachable
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func isInternetReachable() -> Bool {
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            return true
        case .cellular:
            print("Reachable via Cellular")
            return true
        case .none:
            print("Network not reachable")
            return false
        }
    }
    
}

