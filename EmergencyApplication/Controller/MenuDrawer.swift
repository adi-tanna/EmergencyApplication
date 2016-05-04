//
//  MenuDrawer.swift
//  EmergencyApplication
//
//  Created by Aditya Tanna on 4/15/16.
//  Copyright © 2016 Aditya  Bhandari. All rights reserved.
//

import UIKit

protocol MenuDrawerDelegate {
    func selectIndexInMenu(index : Int32)
}

class MenuDrawer: UIView ,UITableViewDataSource,UITableViewDelegate{
    
    var delegate : MenuDrawerDelegate?
    
    var btnMenu : UIButton?
    
    @IBOutlet var tblMenu: UITableView!

    var arrayMenuOptions = [Dictionary<String,String>]()
    
    override func awakeFromNib() {
        
        self.addSlideMenuButton()
        arrayMenuOptions.append(["title":"Home", "icon":"App_Icon_60pts@3x.png"])
        arrayMenuOptions.append(["title":"Your Emergency Contacts", "icon":"App_Icon_60pts@3x.png"])
        arrayMenuOptions.append(["title":"You're As An Emergency", "icon":"App_Icon_60pts@3x.png"])
        arrayMenuOptions.append(["title":"Logout", "icon":"App_Icon_60pts@3x.png"])
        tblMenu.reloadData()
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return arrayMenuOptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cellMenu")!
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.backgroundColor = UIColor.clearColor()
        
        let lblTitle : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        let imgIcon : UIImageView = cell.contentView.viewWithTag(100) as! UIImageView
        
        imgIcon.image = UIImage(named: arrayMenuOptions[indexPath.row]["icon"]!)
        lblTitle.text = arrayMenuOptions[indexPath.row]["title"]!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.delegate?.selectIndexInMenu(Int32(indexPath.row))
        
    }
    
    //MARK: Adding Menu Button in navigation bar
    func addSlideMenuButton() -> UIBarButtonItem{
        let btnShowMenu = UIButton(type: UIButtonType.System)
        btnShowMenu.setImage(self.defaultMenuImage(), forState: UIControlState.Normal)
        btnShowMenu.frame = CGRectMake(0, 0, 30, 30)
        btnShowMenu.tag = 1010
        btnShowMenu.addTarget(self, action: "onSlideMenuButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        
        return customBarItem
    }
    
    func onSlideMenuButtonPressed(sender : UIButton){
        
        self.hidden = false
        
        if (sender.tag == 10)
        {
            sender.tag = 0;
            
            btnMenu = nil
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                var frameMenu : CGRect = self.frame
                frameMenu.origin.x = -1 * UIScreen.mainScreen().bounds.size.width
                self.frame = frameMenu

                }, completion: { (finished) -> Void in
            })
            return
        }
        sender.enabled = false
        sender.tag = 10
        btnMenu = sender
        self.frame.origin.x = (-1) * UIScreen.mainScreen().bounds.size.width
        self.frame.size.height = UIScreen.mainScreen().bounds.size.height
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.frame.origin.x = 0
             sender.enabled = true
            },completion:nil)
    }
    
    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 22), false, 0.0)
        
        UIColor.blackColor().setFill()
        UIBezierPath(rect: CGRectMake(0, 3, 30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 10, 30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 17, 30, 1)).fill()
        
        UIColor.whiteColor().setFill()
        UIBezierPath(rect: CGRectMake(0, 4, 30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 11,  30, 1)).fill()
        UIBezierPath(rect: CGRectMake(0, 18, 30, 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return defaultMenuImage;
    }    
}
