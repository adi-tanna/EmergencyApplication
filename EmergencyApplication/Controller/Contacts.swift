//
//  Contacts.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 3/16/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class Contacts: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.getAppDelegate().checkContactAuthorization()
        
        if(AppDelegate.getAppDelegate().isAccessGranted){
            print("Access Granted")
        }else{
            print("Access Denied")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
