//
//  EmergencyLocation.swift
//  EmergencyApplication
//
//  Created by Aditya Tanna on 5/19/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

class EmergencyLocation: UIViewController,MKMapViewDelegate {

    var notificationInfo = [NSObject: AnyObject] ()
    
    @IBOutlet var mapEmergency: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    
    var location:CLLocation?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onEmergencyOccurrence(_:)), name:"onMessageReceived", object: nil)
        

        NSLog("This is Notification From Emergency Class %@", notificationInfo)
        
        self.title = "\(notificationInfo["userName"] as! String) is in Emergency"
        
        mapEmergency.delegate = self
        
        displayLocatoinOnMap(notificationInfo)
        
        
        
        //Just Before ending of View Did Load clear Userdefault Notification in order to manage new arriving notification when app is killed.
        
        let userDefaults =  NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(nil , forKey: "remoteNotification");
        
        userDefaults.setObject(nil , forKey: "isRemoteNotificationAvailable");
       
    }
   
    
    func onEmergencyOccurrence(notification: NSNotification){
        
        print("This Emergency Location Class \(notification)")
        
        displayLocatoinOnMap(notification.userInfo!)
    }
    
    func displayLocatoinOnMap(dict:[NSObject: AnyObject]) {
        let latitude:CLLocationDegrees = Double(dict["latitude"] as! String)!
        let longitude:CLLocationDegrees = Double(dict["longitude"] as! String)!
        
        let loc:CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        location = loc
        
        centerMapOnLocation(location!)
        
        mapEmergency.removeAnnotations(mapEmergency.annotations)
        
        // show pin on map
        let artwork = Pin(title: "\(dict["userName"] as! String)'s Location",locationName: "",discipline: "",coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        
        mapEmergency.addAnnotation(artwork)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapEmergency.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let button = UIButton(type: .DetailDisclosure)
                view.rightCalloutAccessoryView = button
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
                 calloutAccessoryControlTapped control: UIControl!) {
        let location = view.annotation as! Pin
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMapsWithLaunchOptions(launchOptions)
    }
}
