//
//  AirportDeparturesViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/7/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



protocol AirportDeparturesViewControllerDelegate: class
{
    func airportDeparturesViewController( airportDeparturesViewController: AirportDeparturesViewController,
                                          didSelectDeparture: String )
 
    func airportDeparturesViewController( airportDeparturesViewController: AirportDeparturesViewController,
                                          didSelectDeparture: String,
                                          withTransistion: String )
}



class AirportDeparturesViewController: UIViewController,
                                       DepartureViewControllerDelegate,
                                       TransitionsViewControllerDelegate,
                                       UITableViewDataSource,
                                       UITableViewDelegate
{
    let CellIdentifier              = "AirportDeparturesCell"
    let STORYBOARD_ID_DEPARTURES    = "DepartureViewController"
    let STORYBOARD_ID_TRANSITIONS   = "TransitionsViewController"

    
    
    @IBOutlet weak var myTableView:     UITableView!
    
    weak var delegate: AirportDeparturesViewControllerDelegate?
    
    var departureAirport:           String!         // Set by delegate
    var departureExtArray =         ExtArray()
    var departuresForAirportKey:    String!
    var segueInProgress:            Bool!
    var tableEditing:               Bool!
    var transition:                 String!
    var transitionSelected:         Bool!
    var useLastDepartureSelection:  Bool!           // Set by delegate
    
    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()

        title = String( format: "%@ Departures", departureAirport )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init( barButtonSystemItem: .add,
                                                                  target: self,
                                                                  action: #selector( plusButtonTapped ) )
        preferredContentSize = CGSize(width: 240, height: 400 )

        departuresForAirportKey = String( format: "%@.%@", GlobalConstants.UserDefaults.KEY_DEPARTURES, departureAirport )

        segueInProgress    = false
        transitionSelected = false
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )

        if !segueInProgress
        {
            reloadData()
            initializeDepartureSelection()
        }

        segueInProgress = false
        myTableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )
        
        if ( !segueInProgress && departureExtArray.elementWasSelected() )
        {
            let     selection = departureExtArray.selectedElement()
            
            UserDefaults.standard.removeObject(   forKey: GlobalConstants.UserDefaults.KEY_LAST_DEPARTURE )
            UserDefaults.standard.set( selection, forKey: GlobalConstants.UserDefaults.KEY_LAST_DEPARTURE )
            
            UserDefaults.standard.synchronize()

            if transitionSelected
            {
                delegate?.airportDeparturesViewController( airportDeparturesViewController: self,
                                                           didSelectDeparture: selection,
                                                           withTransistion: transition )
            }
            else
            {
                delegate?.airportDeparturesViewController( airportDeparturesViewController: self,
                                                           didSelectDeparture: selection )
            }

        }
        
    }
    

    override func didReceiveMemoryWarning()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: DepartureViewControllerDelegate Methods
    
    func departureViewController( departureViewController: DepartureViewController,
                                  didSelectDeparture: String )
    {
        NSLog( "%@:%@[%d] - [ %@ ]", description(), #function, #line, didSelectDeparture )
        departureExtArray.addString( newString: didSelectDeparture )
        
        transition         = GlobalConstants.EMPTY_STRING
        transitionSelected = false
        
        if .pad != UIDevice.current.userInterfaceIdiom
        {
            initializeDepartureSelection()
        }

    }
    
    
    func departureViewController( departureViewController: DepartureViewController,
                                  didSelectDeparture: String,
                                  withTransition: String )
    {
        NSLog( "%@:%@[%d] - [ %@ ][ %@ ]", description(), #function, #line, didSelectDeparture, withTransition )
        departureExtArray.addString( newString: didSelectDeparture )
        
        transition         = withTransition
        transitionSelected = true
        
        if .pad != UIDevice.current.userInterfaceIdiom
        {
            initializeDepartureSelection()
        }

    }
    
    
    
    // MARK: TransitionViewControllerDelegate Methods

    func transitionsViewController( sender: TransitionsViewController,
                                    didSelectTransition: String )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, didSelectTransition )
        transition         = didSelectTransition
        transitionSelected = true
        
        myTableView.reloadData()
    }
    
    
    
    // MARK: Target/Action Methods
    
    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_DEPARTURES )

        navigationController?.pushViewController( myViewController, animated: true )
    }
    
    
    
    // MARK: - UITableViewDataSource Delegate Methods
    
    func tableView(_                    tableView: UITableView,
                    numberOfRowsInSection section: Int ) -> Int
    {
        return departureExtArray.numberOfElements()
    }

    
    func tableView(_             tableView: UITableView,
                    cellForRowAt indexPath: IndexPath ) -> UITableViewCell
    {
        let         cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
//        NSLog( "%@:%@[%d] - selectedElement[ %d ]", description(), #function, #line, departureExtArray.indexOfSelectedElement )

        cell.textLabel?.text = departureExtArray.elementAt( index: indexPath.row )
        cell.accessoryType   = ( ( indexPath.row == departureExtArray.indexOfSelectedElement ) ? .detailDisclosureButton : .none )
        
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
    
    func tableView(_                                tableView: UITableView,
                    accessoryButtonTappedForRowWith indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_TRANSITIONS )
        
        navigationController?.pushViewController( myViewController, animated: true )
    }
    
    
    func tableView(_               tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        departureExtArray.indexOfSelectedElement = ( ( departureExtArray.indexOfSelectedElement == indexPath.row ) ? GlobalConstants.NO_SELECTION : indexPath.row )
        
        tableView.reloadData()
    }

    
    
    // MARK: Utility Methods
    
    func description() -> String
    {
        return "AirportDeparturesViewController"
    }
    
    
    func initializeDepartureSelection()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if useLastDepartureSelection
        {
            let     lastDeparture = UserDefaults.standard.string( forKey: GlobalConstants.UserDefaults.KEY_LAST_DEPARTURE )
            
            if nil != lastDeparture
            {
                departureExtArray.selectElementWithName( elementName: lastDeparture! )
            }

        }
        else
        {
            UserDefaults.standard.removeObject( forKey: GlobalConstants.UserDefaults.KEY_LAST_DEPARTURE )
            UserDefaults.standard.synchronize()
        }
    
    }
    

    func reloadData()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        departureExtArray.initWithName( nameOfArray: "Departures",
                                        lengthMinimum: 2,
                                        keyForNotification: GlobalConstants.EMPTY_STRING,
                                        keyForUserDefault: departuresForAirportKey )
    }


    func viewControllerWithStoryboardId( storyboardId: String ) -> UIViewController
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, storyboardId )
        let     storyboard     = UIStoryboard.init( name: "MainStoryboard_iPad", bundle: nil )
        let     viewController = storyboard.instantiateViewController( withIdentifier: storyboardId )
        
        if storyboardId == STORYBOARD_ID_DEPARTURES
        {
            let     vc = viewController as! DepartureViewController
            
            vc.delegate     = self
            vc.fromSettings = false

            segueInProgress = true
        }
        else if storyboardId == STORYBOARD_ID_TRANSITIONS
        {
            let     vc = viewController as! TransitionsViewController
            
            vc.delegate               = self
            vc.departureName          = departureExtArray.selectedElement()
            vc.fromSettings           = false
            vc.lastTransitionSelected = ( transitionSelected ? transition : GlobalConstants.EMPTY_STRING )
            
            segueInProgress    = true
            transitionSelected = false
            transition         = ""
        }
        
        return viewController
    }
    
}
