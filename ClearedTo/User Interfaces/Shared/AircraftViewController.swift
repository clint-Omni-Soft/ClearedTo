//
//  AircraftViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/2/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



protocol AircraftViewControllerDelegate: class
{
    func aircraftViewController( aircraftViewController: AircraftViewController,
                                 didSelectAircraft: Bool,
                                 withTailNumber: String ) -> Void
}



class AircraftViewController: UIViewController,
                              UITableViewDataSource,
                              UITableViewDelegate
{
    let CellIdentifier = "AircraftCell"

    
    
    @IBOutlet weak var myTableView: UITableView!
    
    weak var delegate:      AircraftViewControllerDelegate?

    var     aircraftExtArray  = ExtArray()
    var     fromSettings:       Bool!       // Set by delegate
    
    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()

        title = "Aircraft"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init( barButtonSystemItem: .add,
                                                                  target: self,
                                                                  action: #selector( plusButtonTapped ) )
        preferredContentSize = CGSize( width: 240, height: 400 )
        
        aircraftExtArray.initWithName( nameOfArray:         "Aircraft",
                                       lengthMinimum:       4,
                                       keyForNotification:  GlobalConstants.Notifications.NOTIFICATION_UPDATE_AIRCRAFT,
                                       keyForUserDefault:   GlobalConstants.UserDefaults.KEY_AIRCRAFT )
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( AircraftViewController.userDefaultsUpdated( notification: ) ),
                                                name:     NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_UPDATE_AIRCRAFT ),
                                                object:   nil )
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )
        
        NotificationCenter.default.removeObserver( self )

        if !fromSettings && aircraftExtArray.elementWasSelected()
        {
            delegate?.aircraftViewController( aircraftViewController: self,
                                              didSelectAircraft: true,
                                              withTailNumber: aircraftExtArray.selectedElement() )
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
        // The reason we are using Notifications is because this view can be up in two different places on the iPad at the same time.
        // This approach allows a change in one to immediately be reflected in the other.
    
        aircraftExtArray.reload()
        myTableView.reloadData()
    }
    
    
    
    // MARK: Target/Action methods
    
    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let     alert        = UIAlertController.init( title: "Add New Aircraft", message: "Enter tail number:", preferredStyle: .alert )
        let     cancelAction = UIAlertAction.init( title: "Cancel", style: .cancel, handler: nil )
        let     okAction     = UIAlertAction.init( title: "OK",     style: .default )
        {
            ( alertAction ) in
            
            let textField     = alert.textFields![0] as UITextField
            let upperCaseName = textField.text!.uppercased()
            
            
            if let errorMessage = self.aircraftExtArray.elementIsValid( elementName: upperCaseName )
            {
                self.presentAlert( title: "Input Error!", message: errorMessage )
            }
            else
            {
                self.aircraftExtArray.addString( newString: upperCaseName )
                self.navigationItem.rightBarButtonItem!.isEnabled = true
            }

        }
        
        alert.addTextField
        {
            ( textField ) in
            
            textField.placeholder = "Enter tail number"
        }
        
        alert.addAction( okAction     )
        alert.addAction( cancelAction )
        
        present( alert, animated: true, completion: nil )
    }

    
    
    // MARK: UITableViewDataSource Methods
    
    func tableView(_                    tableView: UITableView,
                    numberOfRowsInSection section: Int ) -> Int
    {
        return aircraftExtArray.numberOfElements()
    }
    
    
    func tableView(_             tableView: UITableView,
                    cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let     cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = aircraftExtArray.elementAt( index: indexPath.row )
        cell.accessoryType   = .none

        if !fromSettings && ( indexPath.row == aircraftExtArray.indexOfSelectedElement )
        {
            cell.accessoryType = .checkmark
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
                     commit editingStyle: UITableViewCell.EditingStyle,
                      forRowAt indexPath: IndexPath )
    {
        if editingStyle == .delete
        {
            NSLog( "%@:%@[%d] - deleting row[ %d ]", description(), #function, #line, indexPath.row )
            
            aircraftExtArray.deleteStringAtIndex( index: indexPath.row )
        }
        
    }

    
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_               tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - [ %d ]", description(), #function, #line, indexPath.row )
        tableView.deselectRow( at: indexPath, animated: true )
        
        aircraftExtArray.indexOfSelectedElement = ( ( indexPath.row == aircraftExtArray.indexOfSelectedElement ) ? GlobalConstants.NO_SELECTION : indexPath.row )
        
        if ( !fromSettings )
        {
            if aircraftExtArray.elementWasSelected()
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
        return "AircraftViewController"
    }
    
}
