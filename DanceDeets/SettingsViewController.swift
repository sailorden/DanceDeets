//
//  MyCitiesViewController.swift
//  DanceDeets
//
//  Created by David Xiang on 11/27/14.
//  Copyright (c) 2014 david.xiang. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    let MY_LOCATIONS_SECTION:Int = 0
    let TOOLS_SECTION:Int = 1
    
    var cities:[String] = []
    var city:String!
    var autosuggestedCities:[String] = []
    var backgroundBlurView:UIView?
    
    // MARK: Outlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var addCityButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var myCitiesTableView: UITableView!
    
    // MARK: Action
    @IBAction func doneButtonTapped(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    // MARK: UIViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "addCitySegue"){
            let destination = segue.destinationViewController as! AddCityViewController
            let snapShot:UIView = backgroundBlurView!.snapshotViewAfterScreenUpdates(false)
            destination.view.insertSubview(snapShot, atIndex: 0)
            snapShot.constrainToSuperViewEdges()
            destination.settingsVC = self
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        myCitiesTableView.delegate = self
        myCitiesTableView.dataSource = self
        myCitiesTableView.separatorColor = ColorFactory.tableSeparatorColor()
        myCitiesTableView.allowsSelectionDuringEditing = true
        myCitiesTableView.allowsMultipleSelection = false
        
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = FontFactory.navigationTitleFont()
        
        doneButton.titleLabel?.textColor = ColorFactory.white50()
        doneButton.titleLabel?.font = FontFactory.barButtonFont()
        
        city = UserSettings.getUserCitySearch()
        cities = UserSettings.getUserCities()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cities = UserSettings.getUserCities()
        myCitiesTableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == MY_LOCATIONS_SECTION){
            return cities.count + 2
        }else if(section == TOOLS_SECTION){
            return 2
        }else{
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == MY_LOCATIONS_SECTION){
            let header = UILabel(frame: CGRectZero)
            header.text = "MY LOCATIONS"
            header.textAlignment = NSTextAlignment.Center
            header.font = FontFactory.settingsHeaderFont()
            header.textColor = ColorFactory.white50()
            return header
        }else if(section == TOOLS_SECTION){
            let header = UILabel(frame: CGRectZero)
            header.text = "TOOLS"
            header.textAlignment = NSTextAlignment.Center
            header.font = FontFactory.settingsHeaderFont()
            header.textColor = ColorFactory.white50()
            return header
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == MY_LOCATIONS_SECTION){
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCellWithIdentifier("addCityCell", forIndexPath: indexPath) as! AddCityCell
                return cell
            } else if (indexPath.row == cities.count + 1){
                let cell = tableView.dequeueReusableCellWithIdentifier("currentLocationCell", forIndexPath: indexPath) as! CurrentLocationCell
                if(city == ""){
                    cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
                }
                return cell
            } else{
                let cell = tableView.dequeueReusableCellWithIdentifier("citySearchCell", forIndexPath: indexPath) as! CitySearchCell
                cell.settingsVC = self
                cell.deleteButton.hidden = false
                cell.cityLabel.text = cities[indexPath.row - 1]
                if(city == cities[indexPath.row - 1]){
                    cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
                }
                return cell
            }
        }else if(indexPath.section == TOOLS_SECTION){
            if(indexPath.row == 0){
                let cell = tableView.dequeueReusableCellWithIdentifier("sendFeedbackCell", forIndexPath: indexPath) as! SendFeedbackCell
                return cell
            }else {
                let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath) as! LogoutCell
                return cell
            }
            
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("logoutCell", forIndexPath: indexPath) as! LogoutCell
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == MY_LOCATIONS_SECTION){
            if(indexPath.row == 0){
                performSegueWithIdentifier("addCitySegue", sender: self)
            } else if(indexPath.row == cities.count + 1){
                UserSettings.setUserCitySearch("")
                AppDelegate.sharedInstance().eventStreamViewController()?.requiresRefresh = true
                presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            } else{
                UserSettings.setUserCitySearch(cities[indexPath.row - 1])
                AppDelegate.sharedInstance().eventStreamViewController()?.requiresRefresh = true
                presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            }
        }else if(indexPath.section == TOOLS_SECTION){
            if(indexPath.row == 0){
                let composer = MFMailComposeViewController()
                let recipients:[String] = ["feedback@dancedeets.com"]
                composer.mailComposeDelegate = self
                composer.setSubject("Dance Deets Feedback")
                composer.setToRecipients(recipients)
                presentViewController(composer, animated: true, completion: nil)
            }else if(indexPath.row == 1){
                FBSDKAccessToken.setCurrentAccessToken(nil)
                FBSDKProfile.setCurrentProfile(nil)
                
                presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            }
        }
    }
    
    func deleteCityRow(city:String){
        for(var i = 0;i < cities.count; i++){
            if(cities[i] == city){
                let indexPathToDelete = NSIndexPath(forRow: i, inSection: 0)
                let tableIndexPathToDelete = NSIndexPath(forRow: i + 1, inSection: 0)
                cities.removeAtIndex(indexPathToDelete.row)
                UserSettings.deleteUserCity(city)
                myCitiesTableView.deleteRowsAtIndexPaths([tableIndexPathToDelete], withRowAnimation: UITableViewRowAnimation.Automatic)
                return
            }
        }
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
