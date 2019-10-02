//
//  MapViewController.swift
//  w4MapKit
//
//  Created by Xcode User on 2019-09-25.
//  Copyright © 2019 Xcode User. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate , UITableViewDelegate, UITableViewDataSource  {
    
    
    let locationManager = CLLocationManager()
    let initialLocation = CLLocation(latitude: 43.655787, longitude: -79.73953)
    
    let dropPin = MKPointAnnotation()
    // Globalize the Drop Pin to Remove Old Pins
    
    
    let coordinates1 = CLLocation(latitude: 43.855787, longitude: -79.93953)
    let coordinates2 = CLLocation(latitude: 43.455787, longitude: -79.93953)
    let coordinates3 = CLLocation(latitude: 43.455787, longitude: -79.539536)
    let coordinates4 = CLLocation(latitude: 43.855787, longitude: -79.53953)
    let locationCoordinates = [coordinates1,coordinates2,coordinates3,coordinates4,coordinates1]
    
    
    
    @IBOutlet var myMapView : MKMapView!
    @IBOutlet var tbLocEntered : UITextField!
    
    @IBOutlet var tbLocEntered2 : UITextField!
    @IBOutlet var tbLocEntered3 : UITextField!
    
    /*
    var locEnteredText  = tbLocEntered.text!
    var locEnteredText2  = tbLocEntered2.text!
    var locEnteredText3  = tbLocEntered3.text!
    */
    
    //variable for tableview - it is required when using MapKit
    @IBOutlet var myTableView : UITableView!
    
    var routeSteps = ["Enter a destination to see steps"] as NSMutableArray
    
    
    
    //to hide keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //Method to center whatever is typed in textfield
    let regionRadius : CLLocationDistance = 1000
    
    func centerMapOnLocation(location : CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        
        myMapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        centerMapOnLocation(location: initialLocation)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = initialLocation.coordinate
        dropPin.title = "Starting at Sheridan college"
        myMapView.addAnnotation(dropPin)
        myMapView.selectAnnotation(dropPin, animated: true)
        
        drawRect()
        // Do any additional setup after loading the view.
    }
    
    
    //to search for new location and drop pin on it
    @IBAction func findNewLocation(sender : Any)
    {
     
        let locEnteredText  = tbLocEntered.text!
       // let locEntered2Text  = tbLocEntered2.text!
        //let locEntered3Text  = tbLocEntered3.text!
        
        let geoCoder = CLGeocoder()
       
        
        geoCoder.geocodeAddressString(locEnteredText) { (placemarks, error) in
            
            if let placemark = placemarks?.first{
                let coordinates : CLLocationCoordinate2D = placemark.location!.coordinate
                
                let newLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                self.centerMapOnLocation(location: newLocation)
                
                // Resets all existing overlay - Blue Line Erases
                self.myMapView.removeOverlays(self.myMapView.overlays)
                
                // Reset Pin Drop - Red Pin Erases
                self.myMapView.removeAnnotation(self.dropPin)
                
                self.dropPin.coordinate = coordinates
                self.dropPin.title = placemark.name
                self.myMapView.addAnnotation(self.dropPin)
                self.myMapView.selectAnnotation(self.dropPin, animated: true)
                
                //for directions
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.initialLocation.coordinate))
                
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
                
                request.requestsAlternateRoutes = false
                request.transportType = .automobile
                
                
                let directions = MKDirections(request: request)
                directions.calculate(completionHandler: { (response, error) in
                    
                    for route in response!.routes{
                        self.myMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                        
                        self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        self.routeSteps.removeAllObjects()
                        
                        for step in route.steps{
                            self.routeSteps.add(step.instructions)
                        }
                        
                        // Draws Rectangle
                        self.drawRect()
                        
                        self.myTableView.reloadData()
                    }//End of IF
                    
                })
                
            } // If First Place Mark
            
        }// End of Geo Coder Function
    }// End of IBOutlet
    
    //------------------------   Rect Radius Start-------------------------------
    
    func drawRect() {

        let coordinates = locationCoordinates.map { $0.coordinate }
        
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        self.myMapView.addOverlay(polyLine)
    }
   
     //------------------------   Rect Radius Stop -------------------------------
    
    //------------------------   Check Alert Start-------------------------------
    
   
    
    //------------------------   Check Alert Stop -------------------------------
    
    //------------------------   Ploygon Method Start-------------------------------
   /*
    func addAnnotations() {
        myMapView?.delegate = self
        myMapView?.addAnnotations(places)
        
        let overlays = places.map { MKCircle(center: $0.coordinate, radius: 100) }
        myMapView?.addOverlays(overlays)
     
        var locations = places.map { $0.coordinate }
        let polyline = MKPolyline(coordinates: &locations, count: locations.count)
        myMapView?.add(polyline)
    }
    */
    //------------------------   Ploygon Method Stop-------------------------------
    
    
    
    //method to draw route lines
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        tableCell.textLabel?.text = routeSteps[indexPath.row] as? String
        return tableCell
    }
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


