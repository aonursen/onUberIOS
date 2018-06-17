//
//  HomeVC.swift
//  onUber
//
//  Created by Arif Onur Şen on 2.03.2018.
//  Copyright © 2018 LiniaTech. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RevealingSplashView
import Firebase

class HomeVC: UIViewController {

    @IBOutlet weak var requestBtn: ButtonRadius!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerBtn: UIButton!
    @IBOutlet weak var heading2TF: UITextField!
    @IBOutlet weak var headingCircle: RadiusView!
    
    var manager: CLLocationManager?
    var delegate: CenterVCDelegate?
    var regionRadius: CLLocationDistance = 1000
    var tableView = UITableView()
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var selectedItemPlacemark: MKPlacemark? = nil
    var route: MKRoute!
    
    let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "launchScreenIcon")!, iconInitialSize: CGSize(width: 80, height: 80), backgroundColor: UIColor.white)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heading2TF.delegate = self
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthStatus()
        mapView.delegate = self
        centerMapOnUserLocation()
        DataService.instance.REF_DRIVERS.observe(.value) { (snapshot) in
            self.loadDrivers()
        }
        self.view.addSubview(revealingSplashView)
        revealingSplashView.animationType = .heartBeat
        revealingSplashView.startAnimation()
        revealingSplashView.heartAttack = true
        heading2TF.addTarget(self, action: #selector(TextFieldDidChange), for: .editingChanged)
        checkRequestsAlways()
    }
    
    func checkRequestsAlways() {
        UpdateService.instance.observeTrips { (tripDict) in
            if let tripDict = tripDict {
                let pickupCoordinate = tripDict["pickupCoordinate"] as! NSArray
                let tripKey = tripDict["passengerKey"] as! String
                let acceptStatus = tripDict["tripIsAccepted"] as! Bool
                
                if !acceptStatus {
                    DataService.instance.driverIsAvailable(key: (Auth.auth().currentUser?.uid)!, handler: { (success) in
                        if success {
                            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            let pickupVC = storyboard.instantiateViewController(withIdentifier: "PickupVC") as? PickupVC
                            pickupVC?.initData(coordinate: CLLocationCoordinate2D(latitude: pickupCoordinate[0] as! CLLocationDegrees, longitude: pickupCoordinate[1] as! CLLocationDegrees), passengerKey: tripKey)
                            self.present(pickupVC!, animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    @objc func TextFieldDidChange() {
        if heading2TF.text != "" {
            performSearch()
        }
    }
    
    func loadDrivers() {
        DataService.instance.REF_DRIVERS.observeSingleEvent(of: .value, with: { (snapShot) in
            if let driverSnapshot = snapShot.children.allObjects as? [DataSnapshot] {
                for driver in driverSnapshot {
                    if driver.hasChild("userIsDriver") {
                        if driver.hasChild("coordinate") {
                            if driver.childSnapshot(forPath: "isPickupModeEnabled").value as? Bool == true {
                                if let driverDict = driver.value as? Dictionary<String, AnyObject> {
                                    let coordinateArray = driverDict["coordinate"] as! NSArray
                                    let driverCoordinate = CLLocationCoordinate2D(latitude: coordinateArray[0] as! CLLocationDegrees, longitude: coordinateArray[1] as! CLLocationDegrees)
                                    let annotation = DriverAnnotation(coordinate: driverCoordinate, key: driver.key)
                                    
                                    var driverVisible: Bool {
                                        return self.mapView.annotations.contains(where: { (annotation) -> Bool in
                                            if let driverAnnotation = annotation as? DriverAnnotation {
                                                if driverAnnotation.key == driver.key {
                                                    driverAnnotation.update(annotation: driverAnnotation, coordinate: driverCoordinate)
                                                }
                                            }
                                            return false
                                        })
                                    }
                                    
                                    if !driverVisible {
                                        self.mapView.addAnnotation(annotation)
                                    }
                                }
                            } else {
                                for annotation in self.mapView.annotations {
                                    if annotation.isKind(of: DriverAnnotation.self) {
                                        if let annotation = annotation as? DriverAnnotation {
                                            if annotation.key == driver.key {
                                                self.mapView.removeAnnotation(annotation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func checkLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            manager?.startUpdatingLocation()
        } else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func centerMapOnUserLocation() {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    @IBAction func requestBtnPressed(_ sender: Any) {
        UpdateService.instance.updateTripsWithCoordinatesUponRequest()
        requestBtn.animateButton(shouldLoad: true, message: nil)
        self.view.endEditing(true)
        heading2TF.isUserInteractionEnabled = false
    }
    @IBAction func menuBtnPressed(_ sender: Any) {
        delegate?.toggleLeftPanel()
    }
    @IBAction func centerMapPressed(_ sender: Any) {
        DataService.instance.REF_USERS.observeSingleEvent(of: .value) { (snapShot) in
            if let userSnapshot = snapShot.children.allObjects as? [DataSnapshot] {
                for user in userSnapshot {
                    if user.key == Auth.auth().currentUser?.uid {
                        if user.hasChild("tripCoordinate") {
                            self.zoom(mapView: self.mapView)
                        } else {
                            self.centerMapOnUserLocation()
                            self.centerBtn.fadeTo(alphaValue: 0.0, duration: 0.2)
                        }
                    }
                }
            }
        }
    }
    
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            checkLocationAuthStatus()
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    }
}

extension HomeVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        UpdateService.instance.updateUserLocation(coordinate: userLocation.coordinate)
        UpdateService.instance.updateDriverLocation(coordinate: userLocation.coordinate)
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let identifier = "driver"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "driverAnnotation")
            return view
        } else if let annotation = annotation as? PassangerAnnotation {
            let identifier = "passenger"
            var view: MKAnnotationView
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.image = UIImage(named: "currentLocationAnnotation")
            return view
        } else if let annotation = annotation as? MKPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "destination")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "destination")
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: "destinationAnnotation")
            return annotationView
            
        } else {
            return nil
        }
    }
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        centerBtn.fadeTo(alphaValue: 1.0, duration: 0.2)
    }
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = heading2TF.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                self.present(Alert.displayError(title: "Some error occured", message: "\(error!)"), animated: true)
            } else if response!.mapItems.count == 0 {
                self.present(Alert.displayError(title: "No Results", message: "There is no place you entered"), animated: true)
            } else {
                for mapItem in (response?.mapItems)! {
                    self.matchingItems.append(mapItem as MKMapItem)
                    self.tableView.reloadData()
                    self.shouldPresentLoading(false)
                }
            }
        }
    }
    func dropPingFor(placemark: MKPlacemark) {
        selectedItemPlacemark = placemark
        
        for annotation in mapView.annotations {
            if annotation.isKind(of: MKPointAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func searchMapKitPolyLine(mapItem: MKMapItem) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapItem
        request.transportType = MKDirectionsTransportType.automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { (response, error) in
            guard let response = response else {
                self.present(Alert.displayError(title: "Directions Error", message: "\(error!)"), animated: true)
                return
            }
            self.route = response.routes[0]
            self.mapView.add(self.route.polyline)
            self.shouldPresentLoading(false)
        }
    }
    
    func zoom(mapView: MKMapView) {
        if mapView.annotations.count == 0 {
            self.present(Alert.displayError(title: "There isn't any annotation", message: "Please select a destination"), animated: true, completion: nil)
        }
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in mapView.annotations where !annotation.isKind(of: DriverAnnotation.self) {
            topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
            topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
            bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
            bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
        }
        var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 2.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 2.0))
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == heading2TF {
            removeOlds()
            tableView.frame = CGRect(x: 15, y: view.frame.height, width: view.frame.width - 30, height: (view.frame.height / 2) - 100)
            tableView.layer.cornerRadius = 5.0
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "locationCell")
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tag = 18
            tableView.rowHeight = 60
            tableView.separatorStyle = .none
            view.addSubview(tableView)
            animateTableView(shouldShow: true)
            UIView.animate(withDuration: 0.2, animations: {
                self.headingCircle.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == heading2TF {
            shouldPresentLoading(true)
            view.endEditing(true)
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == heading2TF && heading2TF.text == "" {
            UIView.animate(withDuration: 0.2, animations: {
                self.headingCircle.backgroundColor = #colorLiteral(red: 0.9372094225, green: 0.3192563114, blue: 0.2439649536, alpha: 1)
            })
        }
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        matchingItems = []
        tableView.reloadData()
        removeOlds()
        centerMapOnUserLocation()
        return true
    }
    
    func removeOlds() {
        DataService.instance.REF_USERS.child((Auth.auth().currentUser?.uid)!).child("tripCoordinate").removeValue()
        mapView.removeOverlays(mapView.overlays)
        for annotation in mapView.annotations {
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            } else if annotation.isKind(of: PassangerAnnotation.self) {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    func animateTableView(shouldShow: Bool) {
        if shouldShow {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 15, y: 160, width: self.view.frame.width - 30, height: (self.view.frame.height / 2) - 100)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame = CGRect(x: 15, y: self.view.frame.height, width: self.view.frame.width - 30, height: (self.view.frame.height / 2) - 100)
            }, completion: { (finished) in
                if finished {
                    for subview in self.view.subviews {
                        if subview.tag == 18 {
                            subview.removeFromSuperview()
                        }
                    }
                }
            })
        }
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "locationCell")
        let mapItem = matchingItems[indexPath.row]
        cell.textLabel?.text = mapItem.name
        cell.detailTextLabel?.text = mapItem.placemark.title
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldPresentLoading(true)
        let passangerCoordinate = manager?.location?.coordinate
        let passangerAnnotation = PassangerAnnotation(coordinate: passangerCoordinate!, key: (Auth.auth().currentUser?.uid)!)
        heading2TF.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        let selectedResult = matchingItems[indexPath.row]
        DataService.instance.REF_USERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["tripCoordinate": [selectedResult.placemark.coordinate.latitude, selectedResult.placemark.coordinate.longitude]])
        
        dropPingFor(placemark: selectedResult.placemark)
        
        searchMapKitPolyLine(mapItem: selectedResult)
        mapView.addAnnotation(passangerAnnotation)
        view.endEditing(true)
        animateTableView(shouldShow: false)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: self.route.polyline)
        renderer.strokeColor = #colorLiteral(red: 0.3352964303, green: 0.5981455471, blue: 1, alpha: 1)
        renderer.lineWidth = 3
        zoom(mapView: self.mapView)
        return renderer
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if heading2TF.text == "" {
            animateTableView(shouldShow: false)
        }
    }
}

























