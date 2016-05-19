//
//  AsEmergencyContactVC.swift
//  EmergencyApplication
//
//  Created by Aditya Tanna on 4/4/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit

class AsEmergencyContactVC: UIViewController , UITableViewDataSource,UITableViewDelegate{

    @IBOutlet var tblAsEmergency: UITableView!
    
    var arrContacts = [[String: String ]] ()
    
    let objDB = Database.sharedDatabaseInstance.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "You As An Emergency Contact"
       
        getAsEmergencyContacts()
        
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK Get those contact who have added Loggin User as A emergency Contact
    func getContacts(){
        let strPN = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        let strSelectQuery = "select * from contacts where emergency_contact_no = '\(strPN)'"
        
        arrContacts = objDB.selectQuery(strSelectQuery)
    }
    
    
    // MARK : TalbeView Data Source & Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return arrContacts.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        let lblName = cell?.contentView.viewWithTag(100) as! UILabel
        
        let lblNumber = cell?.contentView.viewWithTag(101) as! UILabel
        
        let lblRequestStatus = cell?.contentView.viewWithTag(102) as! UILabel
        
        let btnYes = cell?.contentView.viewWithTag(103) as! UIButton
        
        let btnNo = cell?.contentView.viewWithTag(104) as! UIButton
        
        lblName.text = arrContacts[indexPath.row]["userName"] as String!
        
        lblNumber.text = arrContacts[indexPath.row]["userContactNo"] as String!
        
        if(arrContacts[indexPath.row]["accepted"] as String! == "0"){
            lblRequestStatus.text = "Accept Pending Request"
            btnYes.hidden = false
            btnNo.hidden = false
        }else{
            lblRequestStatus.text = "Request Accepted"
            
            btnYes.hidden = true
            btnNo.hidden = true
        }
        
        return cell!
    }
    
    func getAsEmergencyContacts(){
        
        let userid = NSUserDefaults.standardUserDefaults().integerForKey("userId")
        
        let HttpRequestType:String = "GET"
        
        let parameters:AnyObject? = nil
        
        let is_URL: String = "http://107.196.101.242:8181/EmergencyApp/webapi/users/\(userid)/asEmergencyContact"
        
        AppDelegate.getAppDelegate().showActivityIndicator()
        
        AppDelegate.getAppDelegate().callWebService(is_URL, parameters: parameters, httpMethod: HttpRequestType, completion: { result -> Void in
            
            dispatch_async(dispatch_get_main_queue()){
                
                AppDelegate.getAppDelegate().hideActivityIndicator()
            
                self.parseResponse(result as! [[String : AnyObject]])
                
                if(self.arrContacts.count > 0){
                    dispatch_async(dispatch_get_main_queue()){
                        self.tblAsEmergency.reloadData()
                    }
                }
            }
            }, failure:{ result -> Void in
                
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
            arrContacts.append(localDict)
        }
    }
}
