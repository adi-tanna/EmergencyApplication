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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func btnRegister(sender: AnyObject) {
        
        let fname = txtfldFirstName.text as String!
        
        let lname = txtfldLastName.text as String!
        
        let phone_number = txtfldPhoneNumber.text as String!
        
        let password = txtfldPassword.text as String!
        
        if(phone_number.characters.count == 10){
            
             AppDelegate.getAppDelegate().showActivityIndicator()
            
            registerUser()
            
//            let success = checkIfUserExist(phone_number)
//            
//            if(!success){
//                let strInsertQuery = "insert into UserInfo (first_name,last_name,phone_number, password) values ('\(fname)','\(lname)','\(phone_number)', '\(password)')"
//                
//                objDB.insertQuery(strInsertQuery);
//                
//                let userDefaults =  NSUserDefaults.standardUserDefaults()
//                
//                userDefaults.setValue("\(fname) \(lname)", forKey: "userName");
//                
//                userDefaults.setValue(phone_number as String, forKey: "userId")
//            }else{
//                let alert = UIAlertController(title: "", message: "User with same number is already exist", preferredStyle: UIAlertControllerStyle.Alert)
//                
//                let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
//                    print("Ok Pressed");
//                });
//                
//                alert.addAction(alertActionOk)
//                
//                presentViewController(alert, animated: true, completion: nil)
//                
//            }
            
        }else{
            let alert = UIAlertController(title: "", message: "Invalid Phone Number !", preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                print("Ok Pressed");
            });
            
            alert.addAction(alertActionOk)
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
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
            
            userDefaults.setObject("\(result["fname"]) \(result["lname"])", forKey: "userName");
            
            userDefaults.setValue("\(result["id"])", forKey: "userId")
            
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
}