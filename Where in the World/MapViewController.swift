//
//  ViewController.swift
//  Where in the World
//
//  Created by sunan xiang on 2020/2/11.
//  Copyright © 2020 sunan xiang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, PlacesFavoritesDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView! {
        didSet {mapView.delegate = self}
    }
    
    /* Annotation View */
    @IBOutlet var infoView: UIView!
    @IBOutlet var titleName: UILabel!
    @IBOutlet var infoDescription: UILabel!
    @IBOutlet var star: UIButton!
    
    @IBAction func faveButton(_ sender: Any) {
        performSegue(withIdentifier: "showFave", sender: self)
    }
    
    var locationManager = CLLocationManager()
    
    var annotations = [String: Place]()
    var regions = [CLCircularRegion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        //mapView.showsUserLocation = true
        /* Load the data from data.plist*/
        DataManager.sharedInstance.loadAnnotationFromPlist()
        
        /* set the initial region when the app starts*/
        let initialCoor = CLLocationCoordinate2DMake(DataManager.sharedInstance.initialRegion[0], DataManager.sharedInstance.initialRegion[1])
        let span = MKCoordinateSpan.init(latitudeDelta: DataManager.sharedInstance.initialRegion[2], longitudeDelta: DataManager.sharedInstance.initialRegion[3])
        let initialRegion = MKCoordinateRegion(center: initialCoor, span: span)
        mapView.setRegion(initialRegion, animated: true)
        
        /* Initiate the info view*/
        self.infoView.alpha = 0
        infoDescription.lineBreakMode = .byWordWrapping
        infoDescription.numberOfLines = 0
        
        /* LocationManager setup*/
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        checkPermissions()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        
        /* go through each location*/
        for place in DataManager.sharedInstance.allLocations {
            
            /* Add annotation for each place, and store it in the annotations dictionary*/
            let annotation = Place()
            let coor = CLLocationCoordinate2DMake(place.value.lat, place.value.long)
            annotation.coordinate = coor
            annotation.name = place.key
            annotation.longDescription = place.value.description
            self.annotations[place.key] = annotation
            mapView.addAnnotation(annotation)
            
            /* record each place's region into array */
            let placeRegion = CLCircularRegion(center: coor, radius: 200, identifier: place.key)
            placeRegion.notifyOnExit = true
            locationManager.startMonitoring(for: placeRegion)
            self.regions.append(placeRegion)
        }
    }
    
    func checkPermissions() {
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch authStatus {
        case .notDetermined, .denied, .restricted:
            locationManager.requestWhenInUseAuthorization()
            checkPermissions()
            return
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            return
        default:
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized!")
        case .notDetermined:
            print("We need to request authorization")
            manager.requestWhenInUseAuthorization()
        default:
            print("Not authorized :(")
            manager.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
        if state == CLRegionState.inside {
            let alert = UIAlertController(title: "You are closed to one place of interests", message: region.identifier, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FavoritesViewController {
            destination.delegate = self
        }
    }
    
    func favoritePlace(name: String) {
        /* zoom to the chosen place and show the annotation of this place*/
        let location = DataManager.sharedInstance.allLocations[name]
        let favCoor = CLLocationCoordinate2DMake(location!.lat, location!.long)
        let span = MKCoordinateSpan.init(latitudeDelta: DataManager.sharedInstance.initialRegion[2], longitudeDelta: DataManager.sharedInstance.initialRegion[3])
        let initialRegion = MKCoordinateRegion(center: favCoor, span: span)
        mapView.setRegion(initialRegion, animated: true)
        mapView.selectAnnotation(self.annotations[name]!, animated: true)
    }

    
}
    
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotation = annotation as! Place
            let identifier = "CustomPin"
            
            var view: PlaceMarkerView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlaceMarkerView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = PlaceMarkerView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x:-5, y:-5)
//                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//                view.leftCalloutAccessoryView = UIImageView(image: UIImage(named: "pin.png"))
            }
            return view
    }
    
    // when the annotation is tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let faveList = UserDefaults.standard.object(forKey: "faveList") as![String]
        let annotation = view.annotation as! Place
        self.infoView.alpha = 1
        self.titleName.text = annotation.name
        self.infoDescription.text = annotation.longDescription
        if faveList.contains(self.titleName.text!) {
            self.star.isSelected = true
        } else {
            self.star.isSelected = false
        }
        self.star.addTarget(self, action: #selector(starTapped), for: .touchDown)
    }
    
    // When the star is tapped
    @objc func starTapped(_ button: UIButton!){
        let faveList = UserDefaults.standard.object(forKey: "faveList") as![String]

        if self.star.isSelected {
            print(self.titleName.text!)
            DataManager.sharedInstance.deleteFavorite(location: self.titleName.text!)
            self.star.isSelected = false
            print(faveList)
        } else {
            print(self.titleName.text!)
            DataManager.sharedInstance.saveFavorites(location: self.titleName.text!)
            self.star.isSelected = true
            print(faveList)


        }
    }
   


}
