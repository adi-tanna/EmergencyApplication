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
    
    var arrAllContacts = [Dictionary <String, String>] () /* In order to add contact into Arr */

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
        
        let strPN = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        let strSelectQuery = "select * from contacts where user_contact_no = '\(strPN)'"
        
        arrAllContacts = objDB.selectQuery(strSelectQuery)
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
            
            var arr = [Dictionary <String, String>] ()
            
            var dict = Dictionary <String, String>()
            
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
                    
                    dict["contact_type"] = "\(strLable)"
                    
                    dict["emergency_contact_no"] = strNumber
                    
                    dict["emergency_contact_name"] = strName
                    
                    arr.append(dict)
                }
            }
            askUserForSelection(arr)
        }
    }
    
    func askUserForSelection(arrContacts:[Dictionary <String, String>]) {
        
        if(arrContacts.count > 0){
            
            let actionSheet = UIAlertController(title: "Select Number", message: "", preferredStyle: .ActionSheet)
            
            for (var dict) in arrContacts{
                
                let strLabel =  dict["contact_type"] as String!
                
                let strNumber = dict["emergency_contact_no"] as String!
                
                dict["user_contact_no"] = NSUserDefaults.standardUserDefaults().valueForKey("userId") as! String!
                
                dict["is_accepted"] = "0"
                
                let somethingAction = UIAlertAction(title: "\(strLabel) - \(strNumber)", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                    print("something")
                    
                    let ispresent = self.arrAllContacts.contains({element -> Bool in
                        
                        return (element as [String:String]  == dict)
                        
                    })
                    
                    if(!ispresent as Bool){
                        self.arrAllContacts.append(dict);
                        
                        self.arrToSendSms.append(dict["emergency_contact_no"] as String!)
                        
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
        
        var dict = arrAllContacts[indexPath.row] as Dictionary<String, String>
    
        cell.textLabel?.text = dict["emergency_contact_name"]
        
        cell.detailTextLabel?.text = dict["emergency_contact_no"]
        
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            if(arrToSendSms.contains(arrAllContacts[indexPath.row]["emergency_contact_no"] as String!)){
                print(arrToSendSms);
            
                arrToSendSms.removeAtIndex(arrToSendSms.indexOf(arrAllContacts[indexPath.row]["emergency_contact_no"] as String!)!)
                
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
    
    func btnDonePressed(){
        
        let strDeleteQuery = "delete from contacts";
        
        objDB.deleteQuery(strDeleteQuery);
        
        for (var dict) in arrAllContacts{
            
            let strUserNo = dict["user_contact_no"] as String!
            
            let strLable = dict["contact_type"] as String!
            
            let strNumber = dict["emergency_contact_no"] as String!
            
            let strName = dict["emergency_contact_name"] as String!
            
            let isAccepted = dict["is_accepted"] as String!
            
            let string = "insert into contacts (user_contact_no,emergency_contact_no,emergency_contact_name,contact_type,is_accepted) values ('\(strUserNo)','\(strNumber)','\(strName)','\(strLable)','\(isAccepted)')"
            
            objDB.insertQuery(string);
        }
        
        if(arrToSendSms.count > 0){
//            sendMessageToContacts(arrToSendSms); /*Enable this line to send SMS*/
        }
        
        if(fromHomeVC){
            fromHomeVC = false
            navigationController?.popViewControllerAnimated(true);
        }else{
            navigationController?.popToRootViewControllerAnimated(false)
        }
    }
}