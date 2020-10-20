//
//  LocationManager.swift
//  testMaps
//
//  Created by Kseniya Lukoshkina on 13.10.2020.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import GoogleMaps

final class LocationManager: NSObject {
    static let instance = LocationManager()
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    let locationManager = CLLocationManager()
    
    let location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil)
    var mapView: GMSMapView?
    var marker: GMSMarker? = nil
    var photoImage: UIImage? = nil
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        configureMarkerView()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        self.marker?.map = nil
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
        
        self.marker = GMSMarker()
//        locationManager.requestWhenInUseAuthorization()
    }
    
    func configureMarkerView() {
        if let photoImage = self.photoImage {
            let rect = CGRect(x: 0, y: 0, width: 60, height: 60)
            let markerView = UIView(frame: rect)
            markerView.layer.cornerRadius = markerView.frame.height / 2.0
            markerView.layer.masksToBounds = true
            let imageView = UIImageView(frame: rect)
            imageView.image = photoImage
            markerView.addSubview(imageView)
            self.marker?.iconView = markerView
        }
    }
    
}

//    private func addMarker(coordinate: CLLocationCoordinate2D) {
//        let marker = GMSMarker(position: coordinate)
//        marker.map = mapView
//    }
//}

//extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard let location = locations.last else {return}
//
//        path?.add(location.coordinate)
//        polyline?.path = path
//
//        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 17)
////        mapView.camera = camera
////        addMarker(coordinate: location.coordinate)
//        mapView.animate(to: camera)
//    }

extension LocationManager: CLLocationManagerDelegate {
    
    private func addMarker(coordinate: CLLocationCoordinate2D){
        //delete old marker
        self.marker?.map = nil
        //add create new
//        self.marker = GMSMarker(position: coordinate)
        self.marker?.position = coordinate
        self.marker?.map = mapView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        
        self.location.accept(location)
        addMarker(coordinate: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
