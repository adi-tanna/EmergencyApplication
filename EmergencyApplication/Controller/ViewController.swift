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
    
    var timer: NSTimer?
    
    
    override func viewDidLoad() {

        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onEmergencyOccurrence(_:)), name:"onMessageReceived", object: nil)
        
        let userDefaults =  NSUserDefaults.standardUserDefaults()
        
        if let isRemoteNotification = userDefaults.objectForKey("isRemoteNotificationAvailable"){
            if isRemoteNotification as! Bool == true {
                
                let userInfo =  userDefaults.objectForKey("remoteNotification") as? [NSObject:AnyObject]
        
                NSNotificationCenter.defaultCenter().postNotificationName("onMessageReceived", object: nil,userInfo: userInfo)
            }
        }
       
        
        vwMenuDrawer.hidden = true
        
        vwMenuDrawer.delegate = self
        
        self.navigationController?.navigationItem.hidesBackButton = true

        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            Map.showsUserLocation = true
        }
        
        self.navigationItem.leftBarButtonItem = vwMenuDrawer.addSlideMenuButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        if AppDelegate.getAppDelegate().checkLocationService() {
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                Map.showsUserLocation = true
            }
        }else{
            let alert = UIAlertController(title: "Location Services Disable", message: "Location services on your device is turned off. In order to share your location, please enable location services in the Settigs app under Privacy, Location Services.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in
                print("")
                UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=Privacy&path=LOCATION")!)
                //UIApplicationOpenSettingsURLString
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (alert: UIAlertAction!) in
                print("")
            }))
            
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func onEmergencyOccurrence(notification: NSNotification){
        
        print(notification)
        let VCs = (self.navigationController!.childViewControllers) as [UIViewController]
        
        if !VCs.last!.isKindOfClass(EmergencyLocation) {
            let story:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let objVC:EmergencyLocation =  story.instantiateViewControllerWithIdentifier("emergencyLocationVC") as! EmergencyLocation
            
            objVC.notificationInfo = notification.userInfo!
            
            self.navigationController!.pushViewController(objVC, animated: true)
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if(self.vwMenuDrawer.btnMenu != nil){
            self.vwMenuDrawer.onSlideMenuButtonPressed(self.vwMenuDrawer.btnMenu!)
        }
    }
    
    
    //MARK: Menu View Delegate Methods
    func selectIndexInMenu(index : Int32) {
        let topViewController : UIViewController = self.navigationController!.topViewController!
        print("View Controller is : \(topViewController) \n", terminator: "")
        
        if(index == 3){
             AppDelegate.getAppDelegate().unRegisterForGCM()
            self.vwMenuDrawer.hidden = true
        }
        else{
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
    
     //MARK: Declare Emergency
    @IBAction func btnActnDeclareEmergency(sender: UIButton) {
        if AppDelegate.getAppDelegate().checkLocationService() {
            if sender.selected {
                timer?.invalidate()
                sender.selected = false
            }else{
                sender.selected = true
                
                declareEmergency()
                
                timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(ViewController.declareEmergency), userInfo: nil, repeats: true)
            }
        }else{
            let alert = UIAlertController(title: "Location Services Disable", message: "Location services on your device is turned off. In order to share your location, please enable location services in the Settigs app under Privacy, Location Services.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in
                print("")
                UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=Privacy&path=LOCATION")!)
                //UIApplicationOpenSettingsURLString
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (alert: UIAlertAction!) in
                print("")
            }))
            
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    }
    func declareEmergency() -> Void {
        
        let url = "http://107.196.101.242:8181/EmergencyApp/webapi/users/DeclareEmergency"
        
        let userdefaults = NSUserDefaults.standardUserDefaults()
        
        var dict = [String: String] ()

        dict["userName"] = userdefaults.valueForKey("userName") as? String
        dict["contactNo"] = userdefaults.valueForKey("userContactNo") as? String
        dict["latitude"] = "\(coord.latitude)"
        dict["longitude"] = "\(coord.longitude)"
        
        AppDelegate.getAppDelegate().callWebService(url, parameters: dict, httpMethod: "POST", completion: { (result) in
            if(result["message"] as! String == "Successfull !!!"){
                print(result["message"])
            }else{
                let alert = UIAlertController(title: "Alert", message: result["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                
                let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                     self.timer?.invalidate()
                });
                
                alert.addAction(alertActionOk)
                dispatch_async(dispatch_get_main_queue()){
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }, failure:{ result -> Void in
            let alert = UIAlertController(title: "Alert", message: "Something Went Wrong while Declaring Emergency", preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                self.timer?.invalidate()
            });
            
            alert.addAction(alertActionOk)
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
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