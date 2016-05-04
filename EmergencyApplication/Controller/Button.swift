//
//  Button.swift
//  EmergencyApplication
//
//  Created by Aditya  Bhandari on 1/11/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit

class Button: UIButton {
    class Button: UIButton {
        
        override func drawRect(rect: CGRect) {
            let path = UIBezierPath(ovalInRect: rect)
            UIColor.greenColor().setFill()
            path.fill()
            }
        }
    }

