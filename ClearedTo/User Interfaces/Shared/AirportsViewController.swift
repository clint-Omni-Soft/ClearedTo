//
//  AirportsViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/5/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



struct AirportModes
{
    static let eShowDestination = 1
    static let eShowDeparture   = 2
    static let eShowSettings    = 3
}



protocol AirportsViewControllerDelegate: class
{
    func airportsViewController( airportsViewController: AirportsViewController,
                                 didSelectDeparture: Bool,
                                 fromAirport: String ) -> Void
    
    func airportsViewController( airportsViewController: AirportsViewController,
                                 didSelectDestination: Bool,
                                 toAirport: String ) -> Void
}



// MARK: UIViewController Lifecycle Methods

class AirportsViewController: UIViewController,
                              UITableViewDataSource,
                              UITableViewDelegate
{
    let CellIdentifier = "AirportCell"
    
    
    
    @IBOutlet weak var myTableView:     UITableView!
    
    weak var delegate:          AirportsViewControllerDelegate?

    var airportExtArray       = ExtArray()
    var displayMode:            Int!        // Set by delegate
    var tableEditing:           Bool!

    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem.init( barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector( plusButtonTapped ) )
        preferredContentSize = CGSize( width: 240, height: 400 )

        airportExtArray.initWithName( nameOfArray: "Airports",
                                      lengthMinimum: 3,
                                      keyForNotification: GlobalConstants.Notifications.NOTIFICATION_UPDATE_AIRPORTS,
                                      keyForUserDefault:  GlobalConstants.UserDefaults.KEY_AIRPORTS )
        switch displayMode
        {
            case AirportModes.eShowDeparture:       title = "Departure";        break
            case AirportModes.eShowDestination:     title = "Destination";      break
            
            default:    title = "Airports"      // eShowSettings
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( AircraftViewController.userDefaultsUpdated( notification: ) ),
                                                name:     NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_UPDATE_AIRPORTS ),
                                                object:   nil )
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )
        
        NotificationCenter.default.removeObserver( self )
        
        if airportExtArray.elementWasSelected()
        {
            if AirportModes.eShowDeparture == displayMode
            {
                delegate?.airportsViewController( airportsViewController: self, didSelectDeparture: true, fromAirport: airportExtArray.selectedElement() )
            }
            else if AirportModes.eShowDestination == displayMode
            {
                delegate?.airportsViewController( airportsViewController: self, didSelectDestination: true, toAirport: airportExtArray.selectedElement() )
            }

        }
        
    }
    
    
    override func didReceiveMemoryWarning()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.didReceiveMemoryWarning()
    }

    
    
    // MARK: NSNotification Methods
    
    @objc func userDefaultsUpdated( notification: NSNotification )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        // The reason we are using Notifications is because this view can be up in two different places on the iPad at the same time.
        // This approach allows a change in one to immediately be reflected in the other.
        
        airportExtArray.reload()
        myTableView.reloadData()
    }


    
    // MARK: Target/Action methods
    
    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let alert        = UIAlertController.init( title: "Add New Airport", message: "Enter Airport ID:", preferredStyle: UIAlertControllerStyle.alert )
        let cancelAction = UIAlertAction.init( title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil )
        let okAction     = UIAlertAction.init( title: "OK",     style: UIAlertActionStyle.default )
        {
            ( alertAction ) in
            
            let textField     = alert.textFields![0] as UITextField
            let upperCaseName = textField.text!.uppercased()
            
            
            if let errorMessage = self.airportExtArray.elementIsValid( elementName: upperCaseName )
            {
                self.presentAlert( title: "Input Error!", message: errorMessage )
            }
            else
            {
                self.airportExtArray.addString( newString: upperCaseName )
                self.navigationItem.rightBarButtonItem!.isEnabled = true
                self.myTableView.reloadData()
            }

        }
        
        alert.addTextField
            {
                ( textField ) in
                
                textField.placeholder = "Enter Airport ID"
            }

        alert.addAction( okAction     )
        alert.addAction( cancelAction )
        
        present( alert, animated: true, completion: nil )
    }
    
    
    
    // MARK: UITableViewDataSource Methods
    
    func tableView(_                    tableView: UITableView,
                    numberOfRowsInSection section: Int ) -> Int
    {
        return airportExtArray.numberOfElements()
    }
    
    
    func tableView(_             tableView: UITableView,
                    cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let     cell = tableView.dequeueReusableCell( withIdentifier: CellIdentifier, for: indexPath )
        
        
        cell.textLabel?.text = airportExtArray.elementAt( index:  indexPath.row )
        cell.accessoryType   = UITableViewCellAccessoryType.none
        
        if ( AirportModes.eShowSettings != displayMode ) && ( indexPath.row == airportExtArray.indexOfSelectedElement )
        {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    
    
    // MARK: UITableView Editing methods
    
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
                     commit editingStyle: UITableViewCellEditingStyle,
                      forRowAt indexPath: IndexPath )
    {
        if editingStyle == .delete
        {
            NSLog( "%@:%@[%d] - deleting row[ %d ]", description(), #function, #line, indexPath.row )
            
            airportExtArray.deleteStringAtIndex( index: indexPath.row )
        }
        
    }
    
    
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_               tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - [ %d ]", description(), #function, #line, indexPath.row )
        tableView.deselectRow( at: indexPath, animated: true )
        
        airportExtArray.indexOfSelectedElement = ( ( indexPath.row == airportExtArray.indexOfSelectedElement ) ? GlobalConstants.NO_SELECTION : indexPath.row )
        
        if displayMode != AirportModes.eShowSettings
        {
            if airportExtArray.elementWasSelected()
            {
                if .pad == UIDevice.current.userInterfaceIdiom
                {
                    dismiss( animated: true, completion: nil )
                }
                else
                {
                    navigationController?.popViewController( animated: true )
                }

            }

        }

        tableView.reloadData()
    }
    
    

    // MARK: Utility Methods
    
    func description() -> String
    {
        return "AirportViewController"
    }
    
    
    

    
}
