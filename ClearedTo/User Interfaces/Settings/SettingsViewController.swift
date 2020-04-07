//
//  SettingsViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 1/30/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



class SettingsViewController: UIViewController,
                              UITableViewDataSource,
                              UITableViewDelegate
{
    let CellIdentifier                      = "SettingsCell"
    let STORYBOARD_ID_AIRCRAFT              = "AircraftViewController"
    let STORYBOARD_ID_AIRPORTS              = "AirportsViewController"
    let STORYBOARD_ID_DEPARTURES            = "DepartureViewController"
    let STORYBOARD_ID_WELCOME               = "WelcomeViewController"

    
    
    @IBOutlet   var myTableView:    UITableView!
    
    var     cellTitleArray      = [String]()
    var     storyboardIdArray   = [String]()

    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
        
        let     aboutButton = UIButton.init( type: .infoLight )
        
        title = "Settings"
        aboutButton.addTarget( self, action: #selector( aboutButtonTouched ), for: .touchUpInside )
        navigationItem.rightBarButtonItem = UIBarButtonItem.init( customView: aboutButton )
        
        cellTitleArray    = [GlobalConstants.UserDefaults.KEY_AIRCRAFT, GlobalConstants.UserDefaults.KEY_AIRPORTS, GlobalConstants.UserDefaults.KEY_DEPARTURES]
        storyboardIdArray = [STORYBOARD_ID_AIRCRAFT, STORYBOARD_ID_AIRPORTS, STORYBOARD_ID_DEPARTURES]
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )

        myTableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.didReceiveMemoryWarning()
    }
   
    
    
    // MARK: Target/Action Methods
    
    @objc func aboutButtonTouched( sender: UIBarButtonItem ) -> Void
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let    vc = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_WELCOME )
        
        navigationController?.pushViewController( vc, animated: true )
    }
    
    
    
    // MARK: UITableViewDataSource Delegate Methods
    
    func tableView(_                    tableView: UITableView,
                    numberOfRowsInSection section: Int ) -> Int
    {
        return cellTitleArray.count
    }
    
    
    func tableView(_             tableView: UITableView,
                    cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let     cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = cellTitleArray[indexPath.row]
        return cell
    }
    
    
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_               tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let     vc = viewControllerWithStoryboardId( storyboardId: storyboardIdArray[indexPath.row] )
        
        tableView.deselectRow( at: indexPath, animated: true )
        navigationController?.pushViewController( vc, animated: true )
    }
    
    
    
    // MARK: Utility methods
    
    func description() -> String
    {
        return "SettingsViewController"
    }
    
    
    func viewControllerWithStoryboardId( storyboardId: String ) -> UIViewController
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, storyboardId )
        let     storyboard     = UIStoryboard.init( name: "MainStoryboard_iPad", bundle: nil )
        let     viewController = storyboard.instantiateViewController( withIdentifier: storyboardId )
        
        if storyboardId == STORYBOARD_ID_AIRCRAFT
        {
            let     vc = viewController as! AircraftViewController

            vc.fromSettings = true
        }
        else if storyboardId == STORYBOARD_ID_AIRPORTS
        {
            let     vc = viewController as! AirportsViewController

            vc.displayMode = AirportModes.eShowSettings
        }
        else if storyboardId == STORYBOARD_ID_DEPARTURES
        {
            let     vc = viewController as! DepartureViewController

            vc.fromSettings = true
        }
        else if storyboardId == STORYBOARD_ID_WELCOME
        {
            let     vc = viewController as! WelcomeViewController
            
            vc.dismissWithTimer = false
        }
        
        return viewController
    }
    
}
