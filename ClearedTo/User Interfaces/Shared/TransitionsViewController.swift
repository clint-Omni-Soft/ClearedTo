//
//  TransitionsViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/7/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



protocol TransitionsViewControllerDelegate: class
{
    func transitionsViewController( sender: TransitionsViewController,
                                    didSelectTransition: String )
}



class TransitionsViewController: UIViewController,
                                 UITableViewDataSource,
                                 UITableViewDelegate
{
    let CellIdentifier = "TransitionsCell"
    
    
    
    @IBOutlet weak var myTableView:     UITableView!
    
    weak var delegate: TransitionsViewControllerDelegate?
    
    var departureName:              String!         // Set by delegate
    var fromSettings:               Bool!           // Set by delegate
    var initialTableLoad:           Bool!
    var lastTransitionSelected:     String!         // Set by delegate
    var tableEditing:               Bool!
    var transitionsExtArray       = ExtArray()
    var transitionsForDepartureKey: String!
    
    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()

        title = departureName
        navigationItem.rightBarButtonItem = UIBarButtonItem.init( barButtonSystemItem: .add,
                                                                  target: self,
                                                                  action: #selector( plusButtonTapped ) )
        preferredContentSize = CGSize( width: 240, height: 400 )
        
        transitionsExtArray.initWithName( nameOfArray: "Transitions",
                                          lengthMinimum: 2,
                                          keyForNotification: GlobalConstants.Notifications.NOTIFICATION_UPDATE_TRANSITIONS,
                                          keyForUserDefault: ( departureName + " " + GlobalConstants.UserDefaults.KEY_TRANSITIONS ) )
        initialTableLoad = true
    }

    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( AircraftViewController.userDefaultsUpdated( notification: ) ),
                                                name:     NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_UPDATE_TRANSITIONS ),
                                                object:   nil )
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )
        
        NotificationCenter.default.removeObserver( self )
        
        if ( !fromSettings && transitionsExtArray.elementWasSelected() )
        {
            delegate?.transitionsViewController(sender: self, didSelectTransition: transitionsExtArray.selectedElement() )
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
        
        transitionsExtArray.reload()
        myTableView.reloadData()
    }

    
    
    // MARK: Target/Action Methods
    
    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let     alert        = UIAlertController.init( title: "Add New Transition", message: "Enter descriptor:", preferredStyle: .alert )
        let     cancelAction = UIAlertAction.init( title: "Cancel", style: .cancel, handler: nil )
        let     okAction     = UIAlertAction.init( title: "OK", style: .default )
        {
            ( alertAction ) in
            
            let textField     = alert.textFields![0] as UITextField
            let upperCaseName = textField.text!.uppercased()
            
            
            if let errorMessage = self.transitionsExtArray.elementIsValid( elementName: upperCaseName )
            {
                self.presentAlert( title: "Input Error!", message: errorMessage )
            }
            else
            {
                self.transitionsExtArray.addString( newString: upperCaseName )
                self.navigationItem.rightBarButtonItem!.isEnabled = true
            }
            
        }
        
        alert.addTextField
            {
                ( textField ) in
                
                textField.placeholder = "Enter descriptor"
            }
        
        alert.addAction( okAction     )
        alert.addAction( cancelAction )
        
        present( alert, animated: true, completion: nil )
    }
    
    
    
    // MARK: UITableViewDataSource Methods
    
    func tableView(_                    tableView: UITableView,
                    numberOfRowsInSection section: Int ) -> Int
    {
        return transitionsExtArray.numberOfElements()
    }
    
    
    func tableView(_             tableView: UITableView,
                    cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let     cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = transitionsExtArray.elementAt( index: indexPath.row )
        cell.accessoryType   = .none
        
        if !fromSettings
        {
            if initialTableLoad
            {
                if lastTransitionSelected == transitionsExtArray.elementAt( index: indexPath.row )
                {
                    transitionsExtArray.indexOfSelectedElement = indexPath.row
                    initialTableLoad = false
                }
                else if indexPath.row == ( transitionsExtArray.numberOfElements() - 1 )
                {
                    initialTableLoad = false
                }
                
            }
            else
            {
                if transitionsExtArray.indexOfSelectedElement == indexPath.row
                {
                    cell.accessoryType = .checkmark
                }

            }
            
        }
        
        return cell
    }
    
    
    
    // MARK: UITableView Editing methods
    
    func tableView(_             tableView: UITableView,
                    canEditRowAt indexPath: IndexPath ) -> Bool
    {
        return true
    }
    
    
    func tableView(_             tableView: UITableView,
                    canMoveRowAt indexPath: IndexPath ) -> Bool
    {
        return false
    }
    
    
    func tableView(_          tableView: UITableView,
                    commit editingStyle: UITableViewCell.EditingStyle,
                     forRowAt indexPath: IndexPath )
    {
        if editingStyle == .delete
        {
            NSLog( "%@:%@[%d] - deleting row[ %d ]", description(), #function, #line, indexPath.row )
            
            transitionsExtArray.deleteStringAtIndex( index: indexPath.row )
            tableView.reloadData()
        }
        
    }
    
    
    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_               tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - [ %d ]", description(), #function, #line, indexPath.row )
        tableView.deselectRow( at: indexPath, animated: true )
        
        transitionsExtArray.indexOfSelectedElement = ( ( indexPath.row == transitionsExtArray.indexOfSelectedElement ) ? GlobalConstants.NO_SELECTION : indexPath.row )

        if transitionsExtArray.elementWasSelected()
        {
            navigationController?.popViewController( animated: true )
        }

        tableView.reloadData()
    }
    
    
    
    // MARK: Utility Methods
    
    func description() -> String
    {
        return "TransitionsViewController"
    }
    
}
