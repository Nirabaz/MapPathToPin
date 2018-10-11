//
//  ViewController.swift
//  MapPathToPin
//
//  Created by Mykhailo Zabarin on 10/11/18.
//  Copyright © 2018 Mykhailo Zabarin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import JGProgressHUD

class MapVC: UIViewController {
    
     //MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var adressTF: UITextView!
    
    //MARK: - Private Variables
    
    private let hud = JGProgressHUD(style: .dark)
    private var myOrder: OrderML?
    private var locationManager = CLLocationManager()
    
    //MARK: - Internal Variables
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        chackIsLocationServicesEnabled()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    //Mark: - IBActions
    
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        getAdress(aLat: locationCoordinate.latitude, aLon: locationCoordinate.longitude)
    }
    
    //MARK: - Private Functions
    
    private func chackIsLocationServicesEnabled() {
        if CLLocationManager.locationServicesEnabled() == true {
            
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
           getCurrentLocation()
        } else {
            Utils.showAlertWithMessage(message: "PLease turn on location services or GPS in your iPhone settings", title: "Error")
        }
    }
    
    private func getCurrentLocation() {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = 1.0
        locationManager.startUpdatingLocation()
    }
    
    private func addPinForOrder() {
        guard let order = myOrder, let lat = Double(order.latitude), let lon = Double(order.longitude) else {return}
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapView.addAnnotation(annotation)
        locationManager.startUpdatingLocation()
        showRouteOnMap(pickupCoordinate: mapView.region.center, destinationCoordinate: annotation.coordinate)
    }
    
    private func showOrderAddress() {
        guard let order = myOrder else {return}
        adressTF.text = "\(order.displayName)"
    }
    
    private func getAdress(aLat: Double, aLon: Double) {
        hud.show(in: self.view)
        let _ = APIManager.shared().getOrderByCoordinates(lat: aLat, lon: aLon) { [weak self](result, response, errMsg) in
            guard let strongSelf = self else { return }
            strongSelf.hud.dismiss()
            if result{
                do{
                    guard let responseDictionary = response else {return}
                    strongSelf.myOrder = try OrderML.self(from: responseDictionary)
                    strongSelf.showOrderAddress()
                    strongSelf.addPinForOrder()
                    print("success")
                } catch {
                    Utils.showAlertWithMessage(message: "Something went wrong", title: "Error!")
                }
            }else{
                if errMsg != nil{
                    Utils.showAlertWithMessage(message: "There is no result for this coordinates", title: "Error!")
                }
            }
        }
    }
    
    private func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let sourceAnnotation = MKPointAnnotation()
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate {[weak self]
            (response, error) -> Void in
            guard let strongSelf = self else {return}
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            let overlays = strongSelf.mapView.overlays
            strongSelf.mapView.removeOverlays(overlays)
            let route = response.routes[0]
            strongSelf.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            strongSelf.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

//MARK:- CLLocationManager Delegates

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
}

//MARK: - MapViewDelegate

extension MapVC: MKMapViewDelegate {
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
}
