//
//  MapController.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 25.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

final class MapController: UIViewController {
    
    weak var delegate: MapControllerDelegate?
    
    private var address: String?
    private var annotation = MKPointAnnotation()
    
    private lazy var gestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        
        gesture.addTarget(self, action: #selector(handleTap))
        
        return gesture
    }()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        
        manager.delegate = self
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        
        return manager
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        mapView.addGestureRecognizer(gestureRecognizer)
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction
    private func userLocation() {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    @IBAction
    private func saveAddressButton() {
        delegate?.addressSaved(address)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction
    private func showRouteButton() {
        showRouteOnMap(pickupCoordinate: mapView.userLocation.coordinate, destinationCoordinate: annotation.coordinate)
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        mapView.showAnnotations([destinationAnnotation], animated: true)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        mapView.removeOverlays(mapView.overlays)
        
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            
            guard let response = response,
                let route = response.routes.first else {
                    self.showAlert(title: "Error", message: "Direction is not available")
                    return
            }
            
            self.mapView.addOverlay((route.polyline), level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        annotation.coordinate = coordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        mapView.addAnnotation(annotation)
        
        setupAddress(coordinate: annotation.coordinate)
    }
    
    func setupAddress(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            guard let placemarks = placemarks,
                let placemark = placemarks.first else { return }
            
            var addressString = ""
            
            if let thoroughfare = placemark.thoroughfare {
                addressString = addressString + thoroughfare
            }
            if let subThoroughfare = placemark.subThoroughfare {
                addressString = addressString + ", " + subThoroughfare
            }
            
            self.addressLabel.text = addressString
            self.address = addressString
        }
    }
}

extension MapController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

extension MapController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
}

protocol MapControllerDelegate: class {
    
    func addressSaved(_ address: String?)
}
