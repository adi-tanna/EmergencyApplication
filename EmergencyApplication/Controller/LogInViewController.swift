//
//  LogInViewController.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 3/16/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var txtfldPassword: UITextField!
    @IBOutlet var txtfldPhoneNumber: UITextField!
    let objDb = Database.sharedDatabaseInstance.sharedInstance
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        print(objDb.getDatabaseFilePath())
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        let Default = NSUserDefaults.standardUserDefaults()
        
        if let strPN = Default.objectForKey("userId"){
            
            if (strPN.length as Int > 0) {
                
                let objVC:ViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("homevc") as! ViewController
                
                self.navigationController?.pushViewController(objVC, animated: true)
            }
        }
        print("View WILL APPER CALLED")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtfldPassword.resignFirstResponder()
        txtfldPhoneNumber.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        AppDelegate.getAppDelegate().hideActivityIndicator()
    }
    
    @IBAction func btnLogIn(sender: AnyObject) {
    
        
        AppDelegate.getAppDelegate().showActivityIndicator()
        
        getLogin()
        
//        let strPhone = txtfldPhoneNumber.text as String!
//        
//        let strPass = txtfldPassword.text as String!
//        let string = "select first_name,last_name,phone_number, password from UserInfo where phone_number = '\(strPhone)' and password = '\(strPass)'"
//        
//        let contactArray = objDb.selectQuery(string)
//    
//        if (contactArray.count > 0) {
//            
//            for (var dict) in contactArray{
//                
//                if(dict["phone_number"] == strPhone && dict["password"] == strPass){
//                    
//                    let userDefaults =  NSUserDefaults.standardUserDefaults()
//                    
//                    userDefaults.setValue("\(dict["first_name"] as String!) \(dict["last_name"] as String!)", forKey: "userName");
//                    
//                    userDefaults.setValue(dict["phone_number"] as String!, forKey: "userId")
//                    
//                    let objVC:ViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("homevc") as! ViewController
//                    
//                    self.navigationController?.pushViewController(objVC, animated: true)
//                    
//                   return
//                }
//            }
//        }
//        let alert = UIAlertController(title: "", message: "Invalid credentials !", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
//           
//        });
//        
//        alert.addAction(alertActionOk)
//        
//        presentViewController(alert, animated: true, completion: nil)
    }
    
    func getLogin(){
        
        let strPhone = txtfldPhoneNumber.text as String!
        
        let strPass = txtfldPassword.text as String!
        
        let is_URL: String = "http://107.196.101.242:8181/EmergencyApp/webapi/users/login?contactNo=\(strPhone)&password=\(strPass)"
        
        AppDelegate.getAppDelegate().callWebService(is_URL, parameters: nil, httpMethod: "GET", completion: { (result) -> Void in
            
            let userDefaults =  NSUserDefaults.standardUserDefaults()
            
            userDefaults.setValue("\(result["fname"]) \(result["lname"])", forKey: "userName");
            
            userDefaults.setValue("\(result["contactNo"])", forKey: "userId")
            
            let objVC:ViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("homevc") as! ViewController
            
            dispatch_async(dispatch_get_main_queue()){
                AppDelegate.getAppDelegate().hideActivityIndicator()
                
                self.navigationController?.pushViewController(objVC, animated: true)
            }
            
            
            
        }, failure:{
                (result) -> Void in
                
                let alert = UIAlertController(title: "", message: result["message"] as? String, preferredStyle: UIAlertControllerStyle.Alert)
                
                let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                    
                });
                
                alert.addAction(alertActionOk)
                dispatch_async(dispatch_get_main_queue()){
                    
                    AppDelegate.getAppDelegate().hideActivityIndicator()
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
        })
    }
    
    // Called when the view is about to made visible. Default does nothing
    override func viewDidAppear(animated: Bool){
        print("View DID APPER CALLED")
        
    }// Called when the view has been fully transitioned onto the screen. Default does notoverride hing
    override func viewWillDisappear(animated: Bool){
        print("View WILL DISAPPER CALLED")
        
    }
    override func viewDidDisappear(animated: Bool){
        print("View DID DISAPPER CALLED")
        
    }
}
