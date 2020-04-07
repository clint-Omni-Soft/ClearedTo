//
//  ClearedToViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 1/30/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



class ClearedToViewController: UIViewController,
                               AircraftViewControllerDelegate,
                               AirportsViewControllerDelegate,
                               RouteViewControllerDelegate,
                               WelcomeViewControllerDelegate
{
    let KEYBOARD_OFFSET: CGFloat        = 160.0
    let SEGUE_ID_AIRCRAFT               = "ShowAircraft"
    let SEGUE_ID_AIRPORT_DEPARTURES     = "ShowAirportDepartures"
    let SEGUE_ID_AIRPORTS_DEPARTURE     = "ShowAirportsForDeparture"
    let SEGUE_ID_AIRPORTS_DESTINATION   = "ShowAirportsForDestination"
    let SEGUE_ID_ROUTE                  = "ShowRoute"
    let SEGUE_ID_WELCOME                = "ShowWelcomeScreen"
    let TIMER_INTERVAL                  = 2.0

    
    
    @IBOutlet weak var backgroundButton:                UIButton!
    @IBOutlet weak var clearBarButtonItem:              UIBarButtonItem!
    @IBOutlet weak var departureAirportButton:          UIButton!
    @IBOutlet weak var departureFrequencyTextField:     UITextField!
    @IBOutlet weak var destinationAirportButton:        UIButton!
    @IBOutlet weak var expectedAltitudeTextField:       UITextField!
    @IBOutlet weak var initialAltitudeTextField:        UITextField!
    @IBOutlet weak var route:                           UITextView!
    @IBOutlet weak var routeButton:                     UIButton!
    @IBOutlet weak var saveBarButtonItem:               UIBarButtonItem!
    @IBOutlet weak var tailNumberButton:                UIButton!
    @IBOutlet weak var timeToExpectedAltitudeTextField: UITextField!
    @IBOutlet weak var transponderCodeTextField:        UITextField!
    
    var activeTextField:    UITextField!
    var myTimer:            Timer!
    var viewMovedUp:        Bool!

    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
        
        title = "Departure"
        loadDefaults()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( ClearedToViewController.showSplashScreen( notification: ) ),
                                                name:     NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_SHOW_SPLASH_SCREEN ),
                                                object:   nil )
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( ClearedToViewController.keyboardWillShow( notification: ) ),
                                                name:     UIResponder.keyboardWillShowNotification,
                                                object:   nil )
        
        myTimer = Timer.scheduledTimer( timeInterval: TIMER_INTERVAL,
                                        target: self,
                                        selector: #selector( timerFired ),
                                        userInfo: nil,
                                        repeats: true )
        activeTextField = nil
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )
        
        NotificationCenter.default.removeObserver( self )
        
        if nil != myTimer
        {
            myTimer.invalidate()
            myTimer = nil
        }
        
   }
    

    override func didReceiveMemoryWarning()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.didReceiveMemoryWarning()
    }

    
    override var shouldAutorotate: Bool
    {
        return false
    }
    
    
    
    // MARK: AircraftViewControllerDelegate Methods
    
    func aircraftViewController( aircraftViewController: AircraftViewController,
                                 didSelectAircraft: Bool,
                                 withTailNumber: String)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if didSelectAircraft
        {
            DispatchQueue.main.async
                {
                    self.tailNumberButton.setTitle( withTailNumber, for: .normal )
                    self.configureBarButtons()
                    self.configureRouteButton()
                }
            
        }
        
    }
    
    
    
    // MARK: AirportsViewControllerDelegate Methods
    
    func airportsViewController( airportsViewController: AirportsViewController,
                                 didSelectDeparture: Bool,
                                 fromAirport: String )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if didSelectDeparture
        {
            DispatchQueue.main.async
                {
                    self.departureAirportButton.setTitle( fromAirport, for: .normal )
                    self.configureBarButtons()
                    self.configureRouteButton()
                }

        }
        
    }
    
    
    func airportsViewController( airportsViewController: AirportsViewController,
                                 didSelectDestination: Bool,
                                 toAirport: String )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if didSelectDestination
        {
            DispatchQueue.main.async
                {
                    self.destinationAirportButton.setTitle( toAirport, for: .normal )
                    self.configureBarButtons()
                    self.configureRouteButton()
                }
            
        }
        
    }

    

    // MARK: NSNotification Methods
    
    @objc func keyboardWillShow( notification: NSNotification )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        
        if ( ( view.frame.origin.y >= 0 ) &&
             ( initialAltitudeTextField       .isFirstResponder ||
               departureFrequencyTextField    .isFirstResponder ||
               expectedAltitudeTextField      .isFirstResponder ||
               timeToExpectedAltitudeTextField.isFirstResponder ||
               transponderCodeTextField       .isFirstResponder  ) )
        {
            adjustView( moveViewUp: true )
        }
        
    }
    
    
    @objc func showSplashScreen( notification: NSNotification )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        performSegue( withIdentifier: SEGUE_ID_WELCOME, sender: self )
    }
    
    
    
    // MARK: RouteViewControllerDelegate Methods
    
    func dismissRouteViewController( sender: RouteViewController )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        navigationController?.popViewController( animated: true )
        configureBarButtons()
    }

    
    func routeViewController( sender: RouteViewController, enteredRoute: String )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        route.text  = enteredRoute
        configureBarButtons()
    }
    
    
    
    // MARK: Target Action Methods
    
    @IBAction func backgroundButtonTouched(_ sender: Any)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        configureViewOnEndOfEditing()
    }
    
    
    @IBAction func clearBarButtonItemTouched(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        resetControls()
        routeButton.isEnabled = false
   }
    
    
    @IBAction func departureAirportButtonTouched(_ sender: Any)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        performSegue( withIdentifier: SEGUE_ID_AIRPORTS_DEPARTURE, sender: self )
   }
  
    
    @IBAction func destinationAirportButtonTouched(_ sender: Any)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        performSegue( withIdentifier: SEGUE_ID_AIRPORTS_DESTINATION, sender: self )
    }
    
    
    @IBAction func routeButtonTouched(_ sender: Any)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        performSegue( withIdentifier: SEGUE_ID_ROUTE, sender: self )
    }
 
    
    @IBAction func saveBarButtonItemTouched(_ sender: UIBarButtonItem)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if !dataInAllFields()
        {
            return
        }
        
        var     clearance               = [String].init()
        var     recentClearancesArray   = [[String]].init()
        let     formattedDate           = DateFormatter.localizedString( from: Date.init(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short )
        
        clearance.append( departureAirportButton.title( for: .normal )! )
        clearance.append( departureFrequencyTextField.text! )
        clearance.append( destinationAirportButton.title( for: .normal )! )
        clearance.append( expectedAltitudeTextField.text! )
        clearance.append( initialAltitudeTextField.text! )
        clearance.append( route.text! )
        clearance.append( tailNumberButton.title( for: .normal )! )
        clearance.append( timeToExpectedAltitudeTextField.text! )
        clearance.append( transponderCodeTextField.text! )
        clearance.append( formattedDate )
        
        if let object = UserDefaults.standard.object( forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES )
        {
            recentClearancesArray = [[String]].init( object as! [[String]] )
            
            recentClearancesArray.insert( clearance, at: 0 )
            
            if GlobalConstants.MAX_CLEARANCES < recentClearancesArray.count
            {
                recentClearancesArray.removeLast()
            }
            
        }
        else
        {
            recentClearancesArray.append( clearance )
        }

        UserDefaults.standard.removeObject(               forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES )
        UserDefaults.standard.set( recentClearancesArray, forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES )
        UserDefaults.standard.synchronize()

        configureBarButtons()
        
        presentAlert( title: "Save Clearance", message: "This clearance has been saved and is viewable on the Recents tab." )
    }
    
    
    @IBAction func tailNumberButtonTouched(_ sender: Any )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        performSegue( withIdentifier: SEGUE_ID_AIRCRAFT, sender: self )
    }

    
    @IBAction func textFieldDidBeginEditing(_ sender: UITextField )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if nil != activeTextField
        {
            // The keyboard is still up but we have changed fields
            if ( initialAltitudeTextField == activeTextField ) || ( expectedAltitudeTextField == activeTextField )
            {
                adjustAltitude( field: activeTextField )
            }
            else if departureFrequencyTextField == activeTextField
            {
                adjustDepartureFrequency()
            }
            
        }
        
        activeTextField = sender
    }
    
    
    @IBAction func textFieldDidEndOnExit(_ sender: UITextField )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        configureViewOnEndOfEditing()
    }
    
    
    
    // MARK: Timer Methods
    
    @objc func timerFired( timer: Timer )
    {
        configureBarButtons()
    }
    
    
    
    // MARK: WelcomeViewControllerDelegate Methods
    
    func dismissWelcomeViewController(welcomeVC: WelcomeViewController)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        navigationController?.popViewController( animated: true )
    }
    
    
    
    // MARK: Utility Methods
    
    func adjustAltitude( field: UITextField )
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let     fieldLength = field.text!.lengthOfBytes( using: String.Encoding.ascii )
        
        switch( fieldLength )
        {
            case 1:    field.text = field.text! + "000";    break
            case 2:    field.text = field.text! + "00";     break
            case 3:    field.text = field.text! + "00";     break
            
            default:    break;
        }
        
        if ( ( field == expectedAltitudeTextField ) &&
             ( initialAltitudeTextField .text != GlobalConstants.EMPTY_STRING ) && ( 0 < ( initialAltitudeTextField .text?.lengthOfBytes( using: String.Encoding.ascii ) )! ) &&
             ( expectedAltitudeTextField.text != GlobalConstants.EMPTY_STRING ) && ( 0 < ( expectedAltitudeTextField.text?.lengthOfBytes( using: String.Encoding.ascii ) )! ) )
        {
            let     initialAltitude :Int? = Int( initialAltitudeTextField .text! )
            let     expectedAltitude:Int? = Int( expectedAltitudeTextField.text! )

            if ( expectedAltitude! < initialAltitude! )
            {
                field.text = field.text! + "0"
            }
            
        }
    
    }
    
    
    func adjustDepartureFrequency()
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let     fieldText   = departureFrequencyTextField.text!
        let     fieldLength = fieldText.lengthOfBytes( using: String.Encoding.ascii )
        
        if ( 3 > fieldLength )
        {
                // We don't really know what we should do with this, so just leave it alone
            return
        }
    
        let     range = fieldText.rangeOfCharacter( from: CharacterSet.init( charactersIn: "." ) )
        
            // Does the string already have a decimal point?
        if nil == range
        {
                // Nope, let's append one if we have 3 digits
            if ( 3 == fieldLength )
            {
                departureFrequencyTextField.text = fieldText + ".0"
            }
            else    // OK, we have more that 3 digits, so insert a decimal point after the 3rd digit
            {
                var     head:String = ""
                var     tail:String = ""
                var     index:Int = 0
                
                
                for digit in fieldText
                {
                    if index < 3
                    {
                        head = head + String( digit )
                    }
                    else
                    {
                        tail = tail + String( digit )
                    }
                    
                    index += 1
                }
                
                departureFrequencyTextField.text = head + "." + tail
            }
        
        }
    
    }
    
    
    func adjustView( moveViewUp: Bool )
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        var     rect = view.frame;
        
        UIView.beginAnimations( nil, context: nil )
        UIView.setAnimationDuration( 0.5 )
        
        if moveViewUp
        {
            // 1. Move the view's origin up so that the text field that will be hidden comes above the keyboard
            // 2. Increase the size of the view so that the area behind the keyboard is covered up
            
            rect.origin.y    -= KEYBOARD_OFFSET
            rect.size.height += KEYBOARD_OFFSET
        }
        else  // Move it back to the normal position
        {
            rect.origin.y    += KEYBOARD_OFFSET
            rect.size.height -= KEYBOARD_OFFSET
        }
        
        viewMovedUp = moveViewUp;
        view.frame = rect;
        
        UIView.commitAnimations()
    }
    
    
    func configureBarButtons()
    {
        let     emptyFieldsPresent = ( GlobalConstants.NO_SELECTION != firstEmptyField() )
        
//        NSLog( "%@:%@[%d] - %@ ", description(), #function, #line, String( format: "emptyFieldsPresent[ %@ ]", stringForBool( boolValue: emptyFieldsPresent ) ) )
        saveBarButtonItem.isEnabled = !emptyFieldsPresent
    }
    
    
    func configureRouteButton()
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        routeButton.isEnabled = ( ( GlobalConstants.EMPTY_STRING != departureAirportButton  .title( for: .normal ) ) &&
                                  ( GlobalConstants.EMPTY_STRING != destinationAirportButton.title( for: .normal ) ) &&
                                  ( GlobalConstants.EMPTY_STRING != tailNumberButton        .title( for: .normal ) ) );
    }
    
    
    func configureViewOnEndOfEditing()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if ( self.viewMovedUp )
        {
            adjustView( moveViewUp: false )
        }
        
        if nil != activeTextField
        {
            activeTextField.resignFirstResponder()
            
            if activeTextField.isEqual( initialAltitudeTextField )
            {
                adjustAltitude( field: activeTextField )
            }
            else if activeTextField.isEqual( expectedAltitudeTextField )
            {
                adjustAltitude( field: activeTextField )
            }
            else if activeTextField.isEqual( departureFrequencyTextField )
            {
                adjustDepartureFrequency()
            }
            
        }
        
        configureBarButtons()
        configureRouteButton()
    }
    

    func dataInAllFields() -> Bool
    {
        var     emptyFieldName = String.init()
    
        switch( firstEmptyField() )
        {
            case GlobalConstants.Clearances.eDepartureAirport:       emptyFieldName = "Departure Airport";        break;
            case GlobalConstants.Clearances.eDepartureFrequency:     emptyFieldName = "Departure Frequency";      break;
            case GlobalConstants.Clearances.eDestinationAirport:     emptyFieldName = "Desitination Airport";     break;
            case GlobalConstants.Clearances.eExpectedAltitude:       emptyFieldName = "Expected Altitude";        break;
            case GlobalConstants.Clearances.eInitialAltitude:        emptyFieldName = "Initial Altitude";         break;
            case GlobalConstants.Clearances.eRouteDescription:       emptyFieldName = "Clearance";                break;
            case GlobalConstants.Clearances.eTailNumber:             emptyFieldName = "Aircraft ID";              break;
            case GlobalConstants.Clearances.eTransponderCode:        emptyFieldName = "Transponder Code";         break;
        
            default:    // case NO_SELECTION
            break;
        }
    
        if ( !emptyFieldName.isEmpty )
        {
            let errorMessage = "The " + emptyFieldName + " field cannot be left blank"
            let alert        = UIAlertController.init( title: "Save Clearance Error", message: errorMessage, preferredStyle: .alert )
            let okAction     = UIAlertAction.init(title: "OK", style: .default, handler: nil )
            
            alert.addAction( okAction )
            
            present( alert, animated: true, completion: nil )
            NSLog( "%@:%@[%d] - %@ [ false ] - %@", description(), #function, #line, errorMessage )

            return false;
        }
    
        if ( 0 == timeToExpectedAltitudeTextField.text?.lengthOfBytes( using: String.Encoding.ascii ) )
        {
            timeToExpectedAltitudeTextField.text = "10";
        }
    
        NSLog( "%@:%@[%d] - [ true ]", description(), #function, #line )

        return true;
    }
    
    
    func description() -> String
    {
        return "ClearedToViewController"
    }
    
    
    func firstEmptyField() -> Int
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if ( GlobalConstants.EMPTY_STRING == tailNumberButton.title(for: .normal ) )
        {
            return GlobalConstants.Clearances.eTailNumber;
        }
        
        if ( GlobalConstants.EMPTY_STRING == departureAirportButton.title( for: .normal ) )
        {
            return GlobalConstants.Clearances.eDepartureAirport;
        }
    
        if ( GlobalConstants.EMPTY_STRING == destinationAirportButton.title(for: .normal ) )
        {
            return GlobalConstants.Clearances.eDestinationAirport;
        }
        
        if ( GlobalConstants.EMPTY_STRING == route.text )
        {
            return GlobalConstants.Clearances.eRouteDescription;
        }
        
        if ( GlobalConstants.EMPTY_STRING == initialAltitudeTextField.text )
        {
            return GlobalConstants.Clearances.eInitialAltitude;
        }
        
        if ( GlobalConstants.EMPTY_STRING == expectedAltitudeTextField.text )
        {
            return GlobalConstants.Clearances.eExpectedAltitude;
        }
        
        if ( GlobalConstants.EMPTY_STRING == departureFrequencyTextField.text )
        {
            return GlobalConstants.Clearances.eDepartureFrequency;
        }
        
        if ( GlobalConstants.EMPTY_STRING == transponderCodeTextField.text )
        {
            return GlobalConstants.Clearances.eTransponderCode;
        }
    
        return GlobalConstants.NO_SELECTION;
    }
    
    
    func loadDefaults()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let     recentClearances = UserDefaults.standard.array( forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES ) as? [[String]]

        resetControls()

        if nil != recentClearances
        {
            let     lastClearance = recentClearances?[0];
            
            departureAirportButton  .setTitle( titleForElement( itemIndex: GlobalConstants.Clearances.eDepartureAirport,   clearance: lastClearance! ), for: .normal )
            destinationAirportButton.setTitle( titleForElement( itemIndex: GlobalConstants.Clearances.eDestinationAirport, clearance: lastClearance! ), for: .normal )
            tailNumberButton        .setTitle( titleForElement( itemIndex: GlobalConstants.Clearances.eTailNumber,         clearance: lastClearance! ), for: .normal )
            
            departureFrequencyTextField     .text = titleForElement( itemIndex: GlobalConstants.Clearances.eDepartureFrequency,     clearance: lastClearance! )
            expectedAltitudeTextField       .text = titleForElement( itemIndex: GlobalConstants.Clearances.eExpectedAltitude,       clearance: lastClearance! )
            initialAltitudeTextField        .text = titleForElement( itemIndex: GlobalConstants.Clearances.eInitialAltitude,        clearance: lastClearance! )
            timeToExpectedAltitudeTextField .text = titleForElement( itemIndex: GlobalConstants.Clearances.eTimeToExpectedAltitude, clearance: lastClearance! )
            transponderCodeTextField        .text = titleForElement( itemIndex: GlobalConstants.Clearances.eTransponderCode,        clearance: lastClearance! )
            
            route.text = titleForElement( itemIndex: GlobalConstants.Clearances.eRouteDescription, clearance: lastClearance! )
        }
    
        viewMovedUp = false
    }
    
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if segue.identifier == SEGUE_ID_AIRCRAFT
        {
            let     vcAircraft: AircraftViewController = segue.destination as! AircraftViewController
            
            vcAircraft.delegate     = self
            vcAircraft.fromSettings = false
        }
        else if segue.identifier == SEGUE_ID_AIRPORTS_DEPARTURE
        {
            let     vcAirports: AirportsViewController = segue.destination as! AirportsViewController
            
            vcAirports.delegate    = self
            vcAirports.displayMode = AirportModes.eShowDeparture
        }
        else if segue.identifier == SEGUE_ID_AIRPORTS_DESTINATION
        {
            let     vcAirports: AirportsViewController = segue.destination as! AirportsViewController
            
            vcAirports.delegate    = self
            vcAirports.displayMode = AirportModes.eShowDestination
        }
        else if segue.identifier == SEGUE_ID_ROUTE
        {
            let     vcRoute: RouteViewController = segue.destination as! RouteViewController

            vcRoute.delegate           = self
            vcRoute.beginningRoute     = route.text;
            vcRoute.departureAirport   = departureAirportButton  .title( for: .normal )
            vcRoute.destinationAirport = destinationAirportButton.title( for: .normal )
        }
        else if segue.identifier == SEGUE_ID_WELCOME
        {
            let     welcomeVC: WelcomeViewController = segue.destination as! WelcomeViewController

            welcomeVC.delegate         = self
            welcomeVC.dismissWithTimer = true
        }
        
    }
    
    
    func resetControls()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        departureAirportButton  .setTitle( GlobalConstants.EMPTY_STRING, for: .normal )
        destinationAirportButton.setTitle( GlobalConstants.EMPTY_STRING, for: .normal )
        tailNumberButton        .setTitle( GlobalConstants.EMPTY_STRING, for: .normal )
        
        departureFrequencyTextField     .text = GlobalConstants.EMPTY_STRING
        expectedAltitudeTextField       .text = GlobalConstants.EMPTY_STRING
        initialAltitudeTextField        .text = GlobalConstants.EMPTY_STRING
        timeToExpectedAltitudeTextField .text = GlobalConstants.EMPTY_STRING
        transponderCodeTextField        .text = GlobalConstants.EMPTY_STRING
        
        route.text = GlobalConstants.EMPTY_STRING
    }

    
    func titleForElement( itemIndex: Int, clearance: [String] )-> String
    {
        let     title = clearance[itemIndex]
    
        return( ( 0 != title.lengthOfBytes(using: String.Encoding.ascii ) ) ? title : String.init() )
    }
    
}
