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
    
    var arrContacts = [Dictionary<String, String >] ()
    
    let objDB = Database.sharedDatabaseInstance.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.title = "You're as An Emergency Contacty"
        
        
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
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel?.text = arrContacts[indexPath.row][""] as String!
        
        cell?.detailTextLabel?.text = arrContacts[indexPath.row][""] as String!
        
        return cell!
    }
}
