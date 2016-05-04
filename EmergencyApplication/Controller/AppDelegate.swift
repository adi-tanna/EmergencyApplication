//
//  AppDelegate.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 1/11/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import Contacts

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

   
    var window: UIWindow?
    var contacts = CNContactStore()
    var isAccessGranted:Bool = false
    var viewActivity:UIView?
    var indicator:UIActivityIndicatorView?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let objDB = Database.sharedDatabaseInstance.sharedInstance
        
        print(objDB.getDatabaseFilePath())
        
        objDB.createDatabaseIfNotExist()
    
        return true
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    
    func callWebService(url: String, parameters: [String: AnyObject]?, httpMethod: String, completion: (result: [String: AnyObject]) -> Void, failure: (result: [String: AnyObject]) -> Void) {
        
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
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
                    
                    print("\(jsonDictionary! as [String:AnyObject])")
                    // 3: Pass the json back to the completion handler
                    
                    completion(result: jsonDictionary!)
                    
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