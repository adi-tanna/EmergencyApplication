
//
//  AppDelegate.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 1/11/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import Contacts
import CoreLocation

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

   
    var window: UIWindow?
    var contacts = CNContactStore()
    var isAccessGranted:Bool = false
    var viewActivity:UIView?
    var indicator:UIActivityIndicatorView?
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {

            let userDefaults =  NSUserDefaults.standardUserDefaults()

            userDefaults.setObject(remoteNotification , forKey: "remoteNotification");
        
            userDefaults.setObject(true , forKey: "isRemoteNotificationAvailable");
            
        }else{
            NSLog("This is normal Launching Option")
        }
        
        let objDB = Database.sharedDatabaseInstance.sharedInstance
        
        print(objDB.getDatabaseFilePath())
        
        objDB.createDatabaseIfNotExist()
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        

        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        let gcmConfig = GCMConfig.defaultConfig()
        
        gcmConfig.receiverDelegate = self
       
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        
           NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.onEmergencyOccurrence(_:)), name:"onMessageReceived", object: nil)
        
        return true
    }
    
    func onEmergencyOccurrence(notification: NSNotification){
        
        print(notification)
        
        let VCs = (self.window?.rootViewController!.childViewControllers)! as [UIViewController]
        
        NSLog("This are VCs when app in open after killing %@", VCs)
    
        if !VCs.last!.isKindOfClass(EmergencyLocation) {
            let story:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let objVC:EmergencyLocation =  story.instantiateViewControllerWithIdentifier("emergencyLocationVC") as! EmergencyLocation
            
            self.window?.rootViewController!.navigationController?.pushViewController(objVC, animated: true)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
      
      
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
     //MARK: GCM Register
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print(registrationToken)
            
            NSUserDefaults.standardUserDefaults().setValue(self
                .registrationToken, forKey: "GCMRegistrationToken")
            
            let Default = NSUserDefaults.standardUserDefaults()
            
            if let strPN = Default.objectForKey("userContactNo"){
                
                if (strPN.length as Int == 10) {
                    
                    AppDelegate.getAppDelegate().registerForGCM()
                }
            }
            
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            print(userInfo);
        }
    }
    
    // [START on_token_refresh]
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: NSData ) {
            // [END receive_apns_token]
            // [START get_gcm_reg_token]
            // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
            let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
            instanceIDConfig.delegate = self
            // Start the GGLInstanceID shared instance with that config and request a registration
            // token to enable reception of notifications
            GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
            self.registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                kGGLInstanceIDAPNSServerTypeSandboxOption:true]
            GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
                scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
            // [END get_gcm_reg_token]
    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
            print("Notification received: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
            // [START_EXCLUDE]
    
        NSNotificationCenter.defaultCenter().postNotificationName("onMessageReceived", object: nil,
                userInfo: userInfo)
            handler(UIBackgroundFetchResult.NewData);
            // [END_EXCLUDE]
    }
    
    func registerForGCM() -> Void {
        let url = "http://107.196.101.242:8181/EmergencyApp/webapi/users/GcmRegister"
        
        var dict = [String : String] ()
        dict["registrationId"] = NSUserDefaults.standardUserDefaults().valueForKey("GCMRegistrationToken") as? String
        dict["contactNo"] = NSUserDefaults.standardUserDefaults().valueForKey("userContactNo") as? String
        
        callWebService(url, parameters: dict, httpMethod: "POST", completion: { (result) in
            result
            if(result["message"] as! String == "Successfull !!!"){
                print(result["message"])
            }else{
                let alert = UIAlertController(title: "Alert", message: "Something Went Wrong while registing for GCM", preferredStyle: UIAlertControllerStyle.Alert)
                
                let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                    
                });
                
                alert.addAction(alertActionOk)
                dispatch_async(dispatch_get_main_queue()){
                    self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }, failure:{ result -> Void in
            let alert = UIAlertController(title: "Alert", message: "Something Went Wrong while registing for GCM", preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                
            });
            
            alert.addAction(alertActionOk)
            dispatch_async(dispatch_get_main_queue()){
                self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
            
        })
    }
    
    func unRegisterForGCM() -> Void {
        let url = "http://107.196.101.242:8181/EmergencyApp/webapi/users/GcmUnRegister"
        
        var dict = [String : String] ()
        dict["registrationId"] = NSUserDefaults.standardUserDefaults().valueForKey("GCMRegistrationToken") as? String
        dict["contactNo"] = NSUserDefaults.standardUserDefaults().valueForKey("userContactNo") as? String
        
        callWebService(url, parameters: dict, httpMethod: "POST", completion: { (result) in
            result
            if(result["message"] as! String == "Successfull !!!"){
                print(result["message"])
            }else{
                let alert = UIAlertController(title: "Alert", message: "Something Went Wrong while Unregisting for GCM", preferredStyle: UIAlertControllerStyle.Alert)
                
                let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                    
                });
                
                alert.addAction(alertActionOk)
                dispatch_async(dispatch_get_main_queue()){
                    self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
            }, failure:{ result -> Void in
                let alert = UIAlertController(title: "Alert", message: "Something Went Wrong while Unregisting for GCM", preferredStyle: UIAlertControllerStyle.Alert)
                
                let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                    
                });
                
                alert.addAction(alertActionOk)
                dispatch_async(dispatch_get_main_queue()){
                    self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                }
                
        })
    }
    
    func checkContactAuthorization () {
        
        let status = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        switch status {
        case .Authorized:
            isAccessGranted = true
            print("Access Granted")
        case .Denied, .NotDetermined:
            
            contacts.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access,err) -> Void in
                if(access) {
                    self.isAccessGranted = true
                    print("Access Granted")
                } else {
                    if status == CNAuthorizationStatus.Denied{
                        self.isAccessGranted = false
                        print("Access Denied")
                    }
                }
            })
        default:
            isAccessGranted = false
        }
    }
    
    func checkLocationService() -> Bool {
        
        var status:Bool = false
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
               status = false
            case .AuthorizedAlways, .AuthorizedWhenInUse:
              status = true
            }
        } else {
            print("Location services are not enabled")
        }
        return status
    }
    
    //MARK: Global App Delegate
    class func getAppDelegate()  -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    //MARK: Show & Hide Activity Indicator with message
    func showActivityIndicator() {
        
        if((viewActivity == nil)){
            viewActivity = UIView(frame: CGRectMake(0, 0, 100, 100))
            viewActivity?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
            indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
            indicator?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
            indicator?.startAnimating()
            
            let lbl:UILabel = UILabel(frame: CGRectMake(3, 0, (viewActivity?.frame.size.width)! - 6, 30))
            lbl.numberOfLines = 0
            lbl.backgroundColor = UIColor.clearColor()
            lbl.textColor = UIColor.whiteColor()
            lbl.font = UIFont(name: "HelveticaNeue", size: 15.0)
            lbl.textAlignment = NSTextAlignment.Center
            lbl.text = "Loading..."
            
            indicator!.center = CGPointMake((viewActivity?.center.x)!, (viewActivity?.center.y)! - ((indicator?.frame.size.height)! / 4))
            
            lbl.center = CGPointMake((viewActivity?.center.x)!, CGRectGetMaxY((indicator?.frame)!) + ((indicator?.frame.size.height)! / 4))
            
            viewActivity?.addSubview(lbl)
        }else{
            indicator?.center = (viewActivity?.center)!
        }
        
        viewActivity?.addSubview(indicator!)
        viewActivity?.layer.cornerRadius = 10
        viewActivity?.center = (self.window?.center)!
        
        self.window?.addSubview(viewActivity!)
    }
    
    func hideActivityIndicator(){
        if(viewActivity != nil){
            indicator?.stopAnimating()
            viewActivity?.removeFromSuperview()
            indicator = nil
            viewActivity = nil
        }
    }
    
    func callWebService(url: String, parameters: AnyObject?, httpMethod: String, completion: (result: AnyObject) -> Void, failure: (result: AnyObject) -> Void) {
        
        let lobj_Request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        lobj_Request.HTTPMethod = httpMethod
        lobj_Request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if(parameters != nil){
            do{
                lobj_Request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters!, options: NSJSONWritingOptions())
            }catch{
                print("Something went wrong")
            }
        }
        let task = session.dataTaskWithRequest(lobj_Request, completionHandler: {data, response, error -> Void in
            
            guard let httpResponse = response as? NSHTTPURLResponse, receivedData = data
                else {
                    print("error: not a valid http response")
                    return
            }
            switch (httpResponse.statusCode) {
            case 200:
                // 2: Create JSON object with data
                do {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments)
                    
                    print(jsonDictionary)
                    // 3: Pass the json back to the completion handler
                    
                    completion(result: jsonDictionary) //as! [[String : AnyObject]]
                    
                } catch {
                    print("error parsing json data")
                }
            default:
                print("GET request got response \(httpResponse.statusCode)")
                do {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
                    
                    print("\(jsonDictionary! as [String:AnyObject])")
                    failure(result: jsonDictionary!)
                    
                } catch {
                    print("error parsing json data")
                }
                
            }
        })
        task.resume()
    }
}