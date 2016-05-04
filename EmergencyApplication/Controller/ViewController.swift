//
//  ViewController.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 1/11/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MessageUI

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, MFMessageComposeViewControllerDelegate,MenuDrawerDelegate {
    
    let locationManager = CLLocationManager()
    
    var coord: CLLocationCoordinate2D!
    
    @IBOutlet var vwMenuDrawer: MenuDrawer!
    
    @IBOutlet weak var Map: MKMapView!
    
    let objDB = Database.sharedDatabaseInstance.sharedInstance
    
    override func viewDidLoad() {

        super.viewDidLoad()

        vwMenuDrawer.hidden = true
        
        vwMenuDrawer.delegate = self
        
        self.navigationController?.navigationItem.hidesBackButton = true

        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        self.navigationItem.leftBarButtonItem = vwMenuDrawer.addSlideMenuButton()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if(self.vwMenuDrawer.btnMenu != nil){
            self.vwMenuDrawer.onSlideMenuButtonPressed(self.vwMenuDrawer.btnMenu!)
        }
    }
    
    func selectIndexInMenu(index : Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        
        if(index == 3){
            self.vwMenuDrawer.hidden = true
        }else{
            dispatch_async(dispatch_get_main_queue()) {
                self.vwMenuDrawer.onSlideMenuButtonPressed(self.vwMenuDrawer.btnMenu!)
            }
        }
        switch(index){
        
        case 0:
            print("Home\n", terminator: "")
            break
        case 1:
            print("Emergency Contact\n", terminator: "")
           performSegueWithIdentifier("vcToPn", sender: self)
            break
        case 2:
            print("You're an an Emergency Contact\n", terminator: "")
            performSegueWithIdentifier("segurAsEmergency", sender: self)
            break
        case 3:
            print("Logout\n", terminator: "")
             self.btnLogOut(self)
            break
        default:
            print("default\n", terminator: "")
            break
        }
    }
    
    //MARK: Location Manager Delegate method
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coord = manager.location!.coordinate
        let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.Map.setRegion(region, animated: true)
        
    }
    
    //MARK: Send SMS Invite
    @IBAction func SendSms(sender: AnyObject) {
        
        let strPN = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        let strSelectQuery = "select * from contacts where user_contact_no = '\(strPN)'"
        
        let arrAllContacts = objDB.selectQuery(strSelectQuery)
        
        print(arrAllContacts)
        
        var arrNumbers = [String]()
        
        for (var dict) in arrAllContacts{
            
            print(dict["emergency_contact_no"] as String!)
            
            arrNumbers.append(dict["emergency_contact_no"] as String!)
        }
        
        let messageVC = MFMessageComposeViewController()
        
        let username = NSUserDefaults.standardUserDefaults().valueForKey("userName") as! String
        
        messageVC.body = "\(username) has added you as an Emergency contact on Emergency App. Please click on link to install app."
        
//        http://maps.apple.com/?q=\(coord.latitude),\(coord.longitude)";
        
        messageVC.recipients = arrNumbers
       
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    //MARK: Go to Emergency Number
    func btnActnGoToNumbers(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier("vcToPn", sender: self)
    }
    
    //MARK: Logout
    func btnLogOut(sender: AnyObject) {
        
        let userDefaults =  NSUserDefaults.standardUserDefaults()
        
        userDefaults.setValue(nil, forKey: "userId")
        
        userDefaults.setValue(nil, forKey: "userName")
        
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "vcToPn"){
            
            let vcNumber:ViewController_PhoneNumbers = segue.destinationViewController as! ViewController_PhoneNumbers
            
            vcNumber.fromHomeVC = true
        }
    }
}