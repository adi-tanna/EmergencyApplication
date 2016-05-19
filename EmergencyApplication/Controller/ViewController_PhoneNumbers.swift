//
//  ViewController_PhoneNumbers.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 2/1/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import ContactsUI
import MessageUI

class ViewController_PhoneNumbers: UIViewController, UITextFieldDelegate, CNContactPickerDelegate,UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate {
    
    //MARK: Outlets and Variables

    @IBOutlet var tblContacts: UITableView!
    
    var fromHomeVC = false
    
    var tagOfSelectTextFeild = 0
    
    var arrAllContacts = [[String : String]] () //[Dictionary <String, String>] () /* In order to add contact into Arr */

    var arrToSendSms = [String] ()
    
    @IBOutlet var txtFields: [UITextField]!
    
    let objDB = Database.sharedDatabaseInstance.sharedInstance
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if(!fromHomeVC){
            let alert = UIAlertController(title: "", message: "Please add your emergency contacts using '+' button on top right corner!", preferredStyle: UIAlertControllerStyle.Alert)
            
            let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                
            });
            
            alert.addAction(alertActionOk)
            
            presentViewController(alert, animated: true, completion: nil)
        }
        
        self.title = "Your Emergency Contacts"
        
        AppDelegate.getAppDelegate().checkContactAuthorization()
        
        self.navigationController?.navigationItem.hidesBackButton = true
        
        let btnDone = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "btnDonePressed")
        
        self.navigationItem.leftBarButtonItem = btnDone
        
        addEmergencyContacts(true)
    }
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
    }
    
    //MARK: Contact Selection Methods
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {

        displayDataIntoField(contact)
    }
    
    func displayDataIntoField(arrData:CNContact) {
        
        if((arrData.phoneNumbers.last) != nil){
            
            let numbers:[CNLabeledValue] = arrData.phoneNumbers
            
            var arr = [[String : String]] ()
            
            var dict =  [String: String]()
            
            if(numbers.count > 0){
                
                let strName:String = String(arrData.givenName).stringByAppendingString(" \(arrData.familyName)")
                
                var strLable:String = ""
                
                var strNumber:String = ""
                
                for number in numbers{
                    
                    if let str1 = number.valueForKey("label"){
                        
                        strLable = String(str1).stringByReplacingOccurrencesOfString("_$!<", withString: "").stringByReplacingOccurrencesOfString(">!$_", withString: "")
                    }
                    
                    if let str2 = (number.valueForKey("value")!.valueForKey("digits")){
                        strNumber = String(str2)
                    }
                    
                    dict["emergencyContactType"] = "\(strLable)"
                    
                    dict["emergencyContactNo"] = strNumber
                    
                    dict["emergencyContactName"] = strName
                    
                    arr.append(dict)
                }
            }
            askUserForSelection(arr)
        }
    }
    
    func askUserForSelection(arrContacts:[[String: String]]) {
        
        if(arrContacts.count > 0){
            
            let actionSheet = UIAlertController(title: "Select Number", message: "", preferredStyle: .ActionSheet)
            
            for (var dict) in arrContacts{
                
                let strLabel =  dict["emergencyContactType"] as String!
                
                let strNumber = dict["emergencyContactNo"]as String!
                
                dict["userContactNo"] = NSUserDefaults.standardUserDefaults().valueForKey("userContactNo") as! String!
                
                dict["userName"] = NSUserDefaults.standardUserDefaults().valueForKey("userName") as! String!
                
                dict["accepted"] = "0"
                
                let somethingAction = UIAlertAction(title: "\(strLabel) - \(strNumber)", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                    
                    let ispresent = self.arrAllContacts.contains({(element:[String : String]) -> Bool in
                          return ((element["emergencyContactNo"]! as String).isEqual(strNumber))
                    })
                    
                    if(!ispresent as Bool){
                        self.arrAllContacts.append(dict);
                        
                        self.arrToSendSms.append(dict["emergencyContactNo"] as String!)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tblContacts.reloadData()
                        })
                        
                    }else{
                        let alert = UIAlertController(title: "", message: "Same Emergency contact already exist in the list", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let alertActionOk = UIAlertAction(title: "Ok", style: .Default, handler: { void in
                            
                        });
                        
                        alert.addAction(alertActionOk)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                })
                
                actionSheet.addAction(somethingAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(alert: UIAlertAction!) in
                print("cancel")})
            
            actionSheet.addAction(cancelAction)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(actionSheet, animated: true, completion: nil)
            })
        }
    }
    
    // MARK: Send Message
    func sendMessageToContacts(arrForSms: [String]) {
        
        let username = NSUserDefaults.standardUserDefaults().valueForKey("userName") as! String
        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "\(username) has added you as an Emergency contact on Emergency App. Please click on link to install app."
        
        //        http://maps.apple.com/?q=\(coord.latitude),\(coord.longitude)";
        
        messageVC.recipients = arrForSms
        
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: true, completion: nil)
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
    
    //MARK: Table view Datasource Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrAllContacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("identifierCell")! as UITableViewCell
        
        var dict = arrAllContacts[indexPath.row] as [String: AnyObject]
    
        cell.textLabel?.text = dict["emergencyContactName"] as! String!
        
        cell.detailTextLabel?.text = (dict["emergencyContactNo"]) as! String!
        
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            if(arrToSendSms.contains(arrAllContacts[indexPath.row]["emergencyContactNo"] as String!)){
                print(arrToSendSms);
            
                arrToSendSms.removeAtIndex(arrToSendSms.indexOf(arrAllContacts[indexPath.row]["emergencyContactNo"] as String!)!)
                
                print(arrToSendSms);
            }
            
            arrAllContacts.removeAtIndex(indexPath.row)
            
            self.tblContacts.reloadData()
           
            print(arrAllContacts)
        }
    }
    
    //MARK: TextField Delegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        let  contactPickerViewController = CNContactPickerViewController ()
        contactPickerViewController.delegate = self
        tagOfSelectTextFeild = textField.tag
        presentViewController(contactPickerViewController, animated: true, completion: nil)
        return false
    }
    
    // MARK: Others
    @IBAction func btnActnAddContact(sender: UIBarButtonItem) {
        let  contactPickerViewController = CNContactPickerViewController ()
       
        contactPickerViewController.delegate = self
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
        
    }
    
    //MARK: Done button Action
    func btnDonePressed(){

        addEmergencyContacts(false)
    }
    
    func addEmergencyContacts(isGetRequest:Bool){
        
        let userid = NSUserDefaults.standardUserDefaults().integerForKey("userId")
        
        var HttpRequestType:String?
        
        var parameters:AnyObject?
        if(isGetRequest){
            HttpRequestType = "GET"
            parameters = nil
        }else{
            HttpRequestType = "POST"
            parameters = arrAllContacts
        }
        
        let is_URL: String = "http://107.196.101.242:8181/EmergencyApp/webapi/users/\(userid)/EmergencyContact"
        
         AppDelegate.getAppDelegate().showActivityIndicator()
        
        AppDelegate.getAppDelegate().callWebService(is_URL, parameters: parameters, httpMethod: HttpRequestType!, completion: { result -> Void in
            
           
            dispatch_async(dispatch_get_main_queue()){
                AppDelegate.getAppDelegate().hideActivityIndicator()
                
                if(isGetRequest){
                    
                    self.parseResponse(result as! [[String : AnyObject]])
                    
                    if(self.arrAllContacts.count > 0){
                        dispatch_async(dispatch_get_main_queue()){
                            self.tblContacts.reloadData()
                        }
                    }
                }else{
                    if(self.arrToSendSms.count > 0){
                        //            sendMessageToContacts(arrToSendSms); /*Enable this line to send SMS*/
                    }
                    if(self.fromHomeVC){
                        self.fromHomeVC = false
                        self.navigationController?.popViewControllerAnimated(true);
                    }else{
                        self.navigationController?.popToRootViewControllerAnimated(false)
                    }
                }
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
    
    func parseResponse(response : [[String:AnyObject]]){
        
        for dict in response{
            
            var localDict = [String: String]()
            
            for (key,value) in dict{

                localDict[key] = "\(value)"
            }
            arrAllContacts.append(localDict)
        }
        
        
    }
}