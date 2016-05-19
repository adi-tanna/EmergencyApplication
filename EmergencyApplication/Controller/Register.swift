//
//  Register.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 3/28/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit

class Register: UIViewController, UITextFieldDelegate {
    let objDB = Database.sharedDatabaseInstance.sharedInstance
    
    @IBOutlet var txtfldCheckPassword: UITextField!
    @IBOutlet var txtfldPassword: UITextField!
    @IBOutlet var txtfldFirstName: UITextField!
    @IBOutlet var txtfldPhoneNumber: UITextField!
    @IBOutlet var txtfldLastName: UITextField!
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    //MARK: Text field Delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    //MARK: Register User Web Service
    func registerUser(){
        /* Web service Starts Here*/
        var dict = [String : String]()
        
        dict["fname"] = txtfldFirstName.text as String!
        dict["lname"] = txtfldLastName.text as String!
        dict["contactNo"] = txtfldPhoneNumber.text as String!
        dict["password"] = txtfldPassword.text as String!
        
        let is_URL: String = "http://107.196.101.242:8181/EmergencyApp/webapi/users"
        
        
        AppDelegate.getAppDelegate().callWebService(is_URL, parameters: dict, httpMethod: "POST", completion: { (result) -> Void in
            let userDefaults =  NSUserDefaults.standardUserDefaults()
            
            let strFullName = "\(result["fname"] as! String) \(result["lname"] as! String)"
            
            let strUserId = "\(result["id"] as! Int)"
            
            let strUserContactNo = "\(result["contactNo"] as! Int)"
        
            userDefaults.setObject(strFullName , forKey: "userName");
            
            userDefaults.setObject(strUserId, forKey: "userId")
        
            userDefaults.setObject(strUserContactNo, forKey: "userContactNo")
            
            AppDelegate.getAppDelegate().registerForGCM()
            
            dispatch_async(dispatch_get_main_queue()){
                
                 AppDelegate.getAppDelegate().hideActivityIndicator()
                
                self.performSegueWithIdentifier("segueAddEmergency", sender: self)
            }
        }, failure: {
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
        /* Web Service Ends Here */
    }
    
    func checkIfUserExist (strPhoneNumber:String) -> Bool{
        
        let strSelectQuery = "select * from UserInfo where phone_number = '\(strPhoneNumber)'"
        
        let userArr =  objDB.selectQuery(strSelectQuery);
        
        if (userArr.count > 0){
            
            for (var dict) in userArr{
                if(dict["phone_number"] == strPhoneNumber){
                    
                    return true;
                }
            }
        }
        return false;
    }
    
    //MARK:Others
    @IBAction func btnRegister(sender: AnyObject) {
        let phone_number = txtfldPhoneNumber.text as String!
    
        if(phone_number.characters.count == 10){
            
            AppDelegate.getAppDelegate().showActivityIndicator()
            
            registerUser()
            
        }else{
            let alert = UIAlertController(title: "", message: "Invalid Phone Number !", preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                print("Ok Pressed");
            });
            
            alert.addAction(alertActionOk)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}