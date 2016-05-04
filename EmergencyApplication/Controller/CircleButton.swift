//
//  CircleButton.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 1/11/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit

class CircleButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.redColor().setFill()
        path.fill()
        
     
        
    }

}
