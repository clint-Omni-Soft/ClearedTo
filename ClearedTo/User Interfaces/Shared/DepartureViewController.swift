//
//  DepartureViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/7/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



protocol DepartureViewControllerDelegate: class
{
    func departureViewController( departureViewController: DepartureViewController,
                                  didSelectDeparture: String )

    func departureViewController( departureViewController: DepartureViewController,
                                  didSelectDeparture: String,
                                  withTransition: String )
}



class DepartureViewController: UIViewController,
                               TransitionsViewControllerDelegate,
                               UITableViewDataSource,
                               UITableViewDelegate
{
    let CellIdentifier              = "DeparturesCell"
    let STORYBOARD_ID_TRANSITIONS   = "TransitionsViewController"

    
    @IBOutlet weak var myTableView:     UITableView!
    
    weak var delegate: DepartureViewControllerDelegate?
    
    var departureExtArray         = ExtArray()
    var fromSettings:               Bool!         // Set by delegate
    var segueInProgress:            Bool!
    var transition:                 String!
    var transitionSelected:         Bool!

    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()

        title = "Departures"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init( barButtonSystemItem: .add,
                                                                  target: self,
                                                                  action: #selector( plusButtonTapped ) )
        preferredContentSize = CGSize( width: 240, height: 400 )
        
        departureExtArray.initWithName( nameOfArray: "Departures",
                                        lengthMinimum: 4,
                                        keyForNotification: GlobalConstants.Notifications.NOTIFICATION_UPDATE_DEPARTURES,
                                        keyForUserDefault:  GlobalConstants.UserDefaults.KEY_DEPARTURES )
        segueInProgress    = false
        transitionSelected = false
    }
    

    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( AircraftViewController.userDefaultsUpdated( notification: ) ),
                                                name:     NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_UPDATE_DEPARTURES ),
                                                object:   nil )
        segueInProgress = false
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )
        
        NotificationCenter.default.removeObserver( self )
        
        if !segueInProgress && !fromSettings && departureExtArray.elementWasSelected()
        {
            if transitionSelected
            {
                delegate?.departureViewController( departureViewController: self,
                                                   didSelectDeparture: departureExtArray.selectedElement(),
                                                   withTransition: transition )
            }
            else
            {
                delegate?.departureViewController( departureViewController: self,
                                                   didSelectDeparture: departureExtArray.selectedElement() ) 
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
        
        departureExtArray.reload()
        myTableView.reloadData()
    }

    
    
    // MARK: TransitionsViewControllerDelegate Methods
    
    func transitionsViewController( sender: TransitionsViewController, didSelectTransition: String )
    {
        NSLog( "%@:%@[%d] - [ %@ ]", description(), #function, #line, didSelectTransition )
        transition         = didSelectTransition
        transitionSelected = true
    }
    
    
    
    // MARK: Target/Action Methods
    
    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let     alert        = UIAlertController.init( title: "Add New Departure", message: "Enter descriptor:", preferredStyle:  .alert )
        let     cancelAction = UIAlertAction.init( title: "Cancel", style: .cancel, handler: nil )
        let     okAction     = UIAlertAction.init( title: "OK",     style: .default )
        {
            ( alertAction ) in
            
            let textField     = alert.textFields![0] as UITextField
            let upperCaseName = textField.text!.uppercased()
            
            
            if let errorMessage = self.departureExtArray.elementIsValid( elementName: upperCaseName )
            {
                self.presentAlert( title: "Input Error!", message: errorMessage )
            }
            else
            {
                self.departureExtArray.addString( newString: upperCaseName )
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
        return departureExtArray.numberOfElements()
    }
    
    
    func tableView(_             tableView: UITableView,
                   cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let     cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
        cell.textLabel?.text = departureExtArray.elementAt( index:  indexPath.row )
        cell.accessoryType   = .none

        if !fromSettings && ( indexPath.row == departureExtArray.indexOfSelectedElement )
        {
            cell.accessoryType = .detailDisclosureButton
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
            
            departureExtArray.deleteStringAtIndex( index: indexPath.row )
            tableView.reloadData()
        }
        
    }
    

    
    // MARK: UITableViewDelegate Methods
    
    func tableView(_                                 tableView: UITableView,
                     accessoryButtonTappedForRowWith indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        presentTransitionsViewController( forDepartureAtIndex: indexPath.row )
    }
    
    
    func tableView(_               tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        tableView.deselectRow( at: indexPath, animated: true )
        
        if fromSettings
        {
            presentTransitionsViewController( forDepartureAtIndex: indexPath.row )
        }
        else
        {
            departureExtArray.indexOfSelectedElement = ( ( indexPath.row == departureExtArray.indexOfSelectedElement ) ? GlobalConstants.NO_SELECTION : indexPath.row )
            tableView.reloadData()
        }
        
    }
    
    
    
    // MARK: Utility Methods
    
    func description() -> String
    {
        return "DepartureViewController"
    }

    
    func presentTransitionsViewController( forDepartureAtIndex: Int )
    {
        let     storyboard     = UIStoryboard.init( name: "MainStoryboard_iPad", bundle: nil )
        let     viewController = storyboard.instantiateViewController( withIdentifier: STORYBOARD_ID_TRANSITIONS ) as! TransitionsViewController
        
        
        viewController.delegate               = self
        viewController.departureName          = departureExtArray.elementAt( index: forDepartureAtIndex )
        viewController.fromSettings           = fromSettings
        viewController.lastTransitionSelected = GlobalConstants.EMPTY_STRING
        NSLog( "%@:%@[%d] - [ %d ] = [ %@ ]", description(), #function, #line, forDepartureAtIndex, viewController.departureName )

        navigationController?.pushViewController( viewController, animated: true )

        segueInProgress = true
    }
    
}
