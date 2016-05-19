//
//  EmergencyLocation.swift
//  EmergencyApplication
//
//  Created by Aditya Tanna on 5/19/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit

class EmergencyLocation: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onEmergencyOccurrence(_:)), name:"onEmergencyOccurrence", object: nil)
    }
    
    func onEmergencyOccurrence(notification: NSNotification){
        
        print(notification)
    }

}
