//
//  RecentsViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 1/29/18.
//  Copyright © 2022 Omni-Soft, Inc. All rights reserved.
//


import UIKit



class RecentsViewController: UIViewController,
                             UITableViewDataSource,
                             UITableViewDelegate
{
    let CellIdentifier          = "RecentsCell"
    let STORYBOARD_ID_CLEARANCE = "ClearanceViewController"

    
    
    @IBOutlet   var myTableView:    UITableView!
    
    var     recentClearances: [[String]]? = nil
    var     selectedClearance             = GlobalConstants.NO_SELECTION
    
    
    
    // MARK: - UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
        
        title = "Recents"
    }
    
    
    override func viewWillAppear(_ animated: Bool )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( RecentsViewController.userDefaultsUpdated(_ :) ),
                                                name: NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_UPDATE_RECENTS ),
                                                object: nil )

        selectedClearance = GlobalConstants.NO_SELECTION
        recentClearances  = UserDefaults.standard.array( forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES ) as? [[String]]
        
        myTableView.reloadData()
    }
    
    
    override func viewDidDisappear(_ animated: Bool )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidDisappear( animated )
        
        NotificationCenter.default.removeObserver( self )
    }

    
    override func didReceiveMemoryWarning()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.didReceiveMemoryWarning()
    }

    
    
    // MARK: - UITableViewDataSource Delegate Methods
    
    func tableView(_                    tableView: UITableView,
                    numberOfRowsInSection section: Int ) -> Int
    {
        var     count = 0
        
        if nil != recentClearances
        {
            count = recentClearances!.count
        }
        
        return count
    }

  
    func tableView(_             tableView: UITableView,
                    cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let     cell      = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        let     clearance = recentClearances![indexPath.row]
        
        cell.detailTextLabel?.text = clearance[GlobalConstants.Clearances.eDateTime]
        cell.textLabel?      .text = String( format: "%@ - %@ in %@", clearance[GlobalConstants.Clearances.eDepartureAirport  ],
                                                                      clearance[GlobalConstants.Clearances.eDestinationAirport],
                                                                      clearance[GlobalConstants.Clearances.eTailNumber        ] )
        return cell
    }
   

    func tableView(_             tableView: UITableView,
                    canEditRowAt indexPath: IndexPath ) -> Bool
    {
        return true
    }


    func tableView(_              tableView: UITableView,
                     canMoveRowAt indexPath: IndexPath ) -> Bool
    {
        return false
    }

    
    func tableView(_           tableView: UITableView,
                     commit editingStyle: UITableViewCell.EditingStyle,
                      forRowAt indexPath: IndexPath )
    {
        if editingStyle == .delete
        {
            NSLog( "%@:%@[%d] - deleting row[ %d ]", description(), #function, #line, indexPath.row )
            
            deleteClearanceAtIndex( index: indexPath.row )
            tableView.reloadData()
        }

    }
    

    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_               tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        tableView.deselectRow( at: indexPath,
                               animated: true )
        
        let     storyboard     = UIStoryboard.init( name: "MainStoryboard_iPad", bundle: nil )
        let     viewController = storyboard.instantiateViewController( withIdentifier: STORYBOARD_ID_CLEARANCE ) as! ClearanceViewController
    
        selectedClearance = indexPath.row
        viewController.selectedClearance = selectedClearance
        
        navigationController?.pushViewController( viewController, animated: true )
    }

    
    
    // MARK: Notification Methods
    
    @objc func userDefaultsUpdated(_ notification: NSNotification )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        recentClearances = UserDefaults.standard.array( forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES ) as? [[String]]

        myTableView.reloadData()
    }
    
 
    
    // MARK: Utility Methods
    
    func deleteClearanceAtIndex( index: Int )
    {
        NSLog( "%@:%@[%d] - [ %d ]", description(), #function, #line, index )

        if ( 1 == recentClearances!.count )
        {
            UserDefaults.standard.removeObject(forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES )
        }
        else
        {
            var newClearancesArray : [[String]] = recentClearances!
            
            newClearancesArray.remove( at: index )
            
            UserDefaults.standard.removeObject(forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES )
            
                // Replace it with our new array
            UserDefaults.standard.set( newClearancesArray, forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES )
        }
        
        UserDefaults.standard.synchronize()
        
        recentClearances = UserDefaults.standard.array( forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES ) as? [[String]]
    }
    
    
    func description() -> String
    {
        return "RecentsViewController"
    }
    
}
