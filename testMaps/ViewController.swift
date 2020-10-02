//
//  ViewController.swift
//  testMaps
//
//  Created by Kseniya Lukoshkina on 25.09.2020.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    private var locationManager: CLLocationManager?
    
    @IBOutlet weak var playImage: UIImageView!
    @IBOutlet weak var stopImage: UIImageView!
    
    var isRunning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLocationManager()
        locationManager?.delegate = self
        
        updateButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateButton()
    }
    
    private func updateButton() {
        if isRunning {
            playImage.isHidden = true
            stopImage.isHidden = false
        } else {
            playImage.isHidden = false
            stopImage.isHidden = true
        }
    }

    @IBAction func clickButton(_ sender: Any) {
        if !isRunning {
            start()
        } else {
            stop()
        }
        isRunning = !isRunning
        updateButton()
    }
    
    private func start() {
        locationManager?.startUpdatingLocation()
    }
    
    private func stop() {
        locationManager?.stopUpdatingLocation()
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
//        locationManager?.requestWhenInUseAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
//        locationManager?.startUpdatingLocation()
    }
    
    private func addMarker(coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {return}
        
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15)
        mapView.camera = camera
        addMarker(coordinate: location.coordinate)
    }
}
