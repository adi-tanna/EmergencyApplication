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
    
    //MARK: View life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let Default = NSUserDefaults.standardUserDefaults()
        
        if let strPN = Default.objectForKey("userContactNo"){
            
            if (strPN.length as Int == 10) {
                
                AppDelegate.getAppDelegate().registerForGCM()
                
                let objVC:ViewController =  self.storyboard?.instantiateViewControllerWithIdentifier("homevc") as! ViewController
                
                self.navigationController?.pushViewController(objVC, animated: false)
            }
        }

        
        print(objDb.getDatabaseFilePath())
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        print("View WILL APPER CALLED")
    }
    
    //MARK: Textfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtfldPassword.resignFirstResponder()
        txtfldPhoneNumber.resignFirstResponder()
        return true
    }
    
    
    //MARK: Touch Based Methods
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        AppDelegate.getAppDelegate().hideActivityIndicator()
    }
    
    //MARK: Login Wes Service
    func getLogin(){
        
        let strPhone = txtfldPhoneNumber.text as String!
        
        let strPass = txtfldPassword.text as String!
        
        let is_URL: String = "http://107.196.101.242:8181/EmergencyApp/webapi/users/login?contactNo=\(strPhone)&password=\(strPass)"
        
        AppDelegate.getAppDelegate().callWebService(is_URL, parameters: nil, httpMethod: "GET", completion: { (result) -> Void in
            
            let userDefaults =  NSUserDefaults.standardUserDefaults()
            
            let strFullName = "\(result["fname"] as! String) \(result["lname"] as! String)"
            
            let strUserId = "\(result["id"] as! Int)"
            
            let strUserContactNo = "\(result["contactNo"] as! Int)"
            
            userDefaults.setObject(strFullName , forKey: "userName");
            
            userDefaults.setObject(strUserId, forKey: "userId")
            
            userDefaults.setObject(strUserContactNo, forKey: "userContactNo")
            
            AppDelegate.getAppDelegate().registerForGCM()
            
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
    //MARK: Others
    @IBAction func btnLogIn(sender: AnyObject) {
        
        AppDelegate.getAppDelegate().showActivityIndicator()
        
        getLogin()
    }
}