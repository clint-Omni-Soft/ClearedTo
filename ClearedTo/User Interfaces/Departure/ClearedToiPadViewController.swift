//
//  ClearedToiPadViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 1/30/18.
//  Copyright © 2022 Omni-Soft, Inc. All rights reserved.
//

import UIKit

class ClearedToiPadViewController: UIViewController,
                                   AircraftViewControllerDelegate,
                                   AirportsViewControllerDelegate,
                                   AirportDeparturesViewControllerDelegate,
                                   HeadingViewControllerDelegate,
                                   UIPopoverPresentationControllerDelegate,
                                   UISplitViewControllerDelegate,
                                   UITextFieldDelegate,
                                   WelcomeViewControllerDelegate
{
    let STORYBOARD_ID_AIRCRAFT              = "AircraftViewController"
    let STORYBOARD_ID_AIRPORTS              = "AirportsViewController"
    let STORYBOARD_ID_AIRPORT_DEPARTURES    = "AirportDeparturesViewController"
    let STORYBOARD_ID_HEADING               = "HeadingViewController"
    let STORYBOARD_ID_WELCOME               = "WelcomeViewController"
    let TIMER_INTERVAL                      = 2.0
    
    
    // Controls at top of page
    @IBOutlet weak var clearBarButtonItem:                  UIBarButtonItem!
    @IBOutlet weak var departureAirportButton:              UIButton!
    @IBOutlet weak var departureFrequencyTextField:         UITextField!
    @IBOutlet weak var destinationAirportButton:            UIButton!
    @IBOutlet weak var expectedAltitudeTextField:           UITextField!
    @IBOutlet weak var initialAltitudeTextField:            UITextField!
    @IBOutlet weak var saveBarButtonItem:                   UIBarButtonItem!
    @IBOutlet weak var tailNumberButton:                    UIButton!
    @IBOutlet weak var timeToExpectedAltitudeTextField:     UITextField!
    @IBOutlet weak var toolbar:                             UIToolbar!
    @IBOutlet weak var transponderCodeTextField:            UITextField!
    @IBOutlet weak var myRouteTextView:                     UITextView!

    // Small Accelerator Buttons - Row 1
    @IBOutlet weak var smallAsFiledButton:                  UIButton!
    @IBOutlet weak var smallClearanceVoidTimeButton:        UIButton!
    @IBOutlet weak var smallClearedToButton:                UIButton!
    @IBOutlet weak var smallClimbButton:                    UIButton!
    @IBOutlet weak var smallCrossButton:                    UIButton!
    @IBOutlet weak var smallDepartureButton:                UIButton!
    @IBOutlet weak var smallDescendButton:                  UIButton!
    @IBOutlet weak var smallDestinationButton:              UIButton!
    @IBOutlet weak var smallDirectToButton:                 UIButton!
    @IBOutlet weak var smallExpectFurtherClearanceButton:   UIButton!
    @IBOutlet weak var smallHeadingButton:                  UIButton!
    @IBOutlet weak var smallDismissKeyboardButton:          UIButton!
    
    // Small Accelerator Buttons - Row 2
    @IBOutlet weak var smallHoldButton:                     UIButton!
    @IBOutlet weak var smallInboundButton:                  UIButton!
    @IBOutlet weak var smallInterceptButton:                UIButton!
    @IBOutlet weak var smallOutboundButton:                 UIButton!
    @IBOutlet weak var smallProcedureTurnButton:            UIButton!
    @IBOutlet weak var smallRadarVectorsButton:             UIButton!
    @IBOutlet weak var smallReportPassingButton:            UIButton!
    @IBOutlet weak var smallRunwayHeadingButton:            UIButton!
    @IBOutlet weak var smallTurnLeftButton:                 UIButton!
    @IBOutlet weak var smallTurnRightButton:                UIButton!
    @IBOutlet weak var smallDeleteWordButton:               UIButton!

    // Big Accelerator Buttons - Row 1
    @IBOutlet weak var bigAsFiledButton:                    UIButton!
    @IBOutlet weak var bigClearanceVoidTimeButton:          UIButton!
    @IBOutlet weak var bigClearedToButton:                  UIButton!
    @IBOutlet weak var bigClimbButton:                      UIButton!
    @IBOutlet weak var bigCrossButton:                      UIButton!
    @IBOutlet weak var bigHeadingButton:                    UIButton!

    // Big Accelerator Buttons - Row 2
    @IBOutlet weak var bigDepartureButton:                  UIButton!
    @IBOutlet weak var bigDescendButton:                    UIButton!
    @IBOutlet weak var bigDestinationButton:                UIButton!
    @IBOutlet weak var bigDirectToButton:                   UIButton!
    @IBOutlet weak var bigExpectFurtherClearanceButton:     UIButton!
    
    // Big Accelerator Buttons - Row 3
    @IBOutlet weak var bigHoldButton:                       UIButton!
    @IBOutlet weak var bigInboundButton:                    UIButton!
    @IBOutlet weak var bigInterceptButton:                  UIButton!
    @IBOutlet weak var bigOutboundButton:                   UIButton!
    @IBOutlet weak var bigProcedureTurnButton:              UIButton!
    @IBOutlet weak var bigDismissKeyboardButton:            UIButton!
    
    // Big Accelerator Buttons - Row 4
    @IBOutlet weak var bigRadarVectorsButton:               UIButton!
    @IBOutlet weak var bigReportPassingButton:              UIButton!
    @IBOutlet weak var bigRunwayHeadingButton:              UIButton!
    @IBOutlet weak var bigTurnLeftButton:                   UIButton!
    @IBOutlet weak var bigTurnRightButton:                  UIButton!
    @IBOutlet weak var bigDeleteWordButton:                 UIButton!

    var activeTextField:                UITextField!
    var airportsMode:                   Int!
    var currentDeleteButton:            UIButton!
    var keyboardIsVisible:              Bool!
    var lastButtonTouchWasDeparture:    Bool!
    var myTimer:                        Timer!
    var routeBeforeDepartureAdded:      String!
    
    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
        
        lastButtonTouchWasDeparture   = false
        splitViewController?.delegate = self
        title                         = "Departure"

        loadDefaults()
        keyboardIsVisible = false
    }

    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        activeTextField = nil
        
        configureAcceleratorButtons()
        
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( keyboardWillShow ),
                                                name:     UIResponder.keyboardWillShowNotification,
                                                object:   nil)
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( keyboardWillHide ),
                                                name:     UIResponder.keyboardWillHideNotification,
                                                object:   nil)
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( showSplashScreen ),
                                                name:     NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_SHOW_SPLASH_SCREEN ),
                                                object:   nil )
        
        myTimer = Timer.scheduledTimer( timeInterval: TIMER_INTERVAL,
                                        target:       self,
                                        selector:     #selector( timerFired ),
                                        userInfo:     nil,
                                        repeats:      true )
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

    
    
    // MARK: AircraftViewControllerDelegate Methods
    
    func aircraftViewController( aircraftViewController: AircraftViewController,
                                 didSelectAircraft: Bool,
                                 withTailNumber: String )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if didSelectAircraft
        {
            DispatchQueue.main.async
                {
                    self.tailNumberButton.setTitle( withTailNumber, for: .normal )
                    
                    self.configureBarButtons()
                }
            
        }
        
    }
    
    
    
    // MARK: AirportDepartureViewControllerDelegate Methods
    
    func airportDeparturesViewController( airportDeparturesViewController: AirportDeparturesViewController,
                                          didSelectDeparture: String )
    {
        NSLog( "%@:%@[%d] - [ %@ ]", description(), #function, #line, didSelectDeparture )
        if lastButtonTouchWasDeparture
        {
            myRouteTextView.text = routeBeforeDepartureAdded
        }
        
        addTextToRoute( additionalText: String( format: "%@ departure ", didSelectDeparture ) )
        lastButtonTouchWasDeparture = true
    }
    
    
    func airportDeparturesViewController( airportDeparturesViewController: AirportDeparturesViewController,
                                          didSelectDeparture: String,
                                          withTransistion: String )
    {
        NSLog( "%@:%@[%d] - [ %@ ][ %@ ]", description(), #function, #line, didSelectDeparture, withTransistion )
        if lastButtonTouchWasDeparture
        {
            myRouteTextView.text = routeBeforeDepartureAdded
        }
        
        addTextToRoute( additionalText: String( format: "%@ departure %@ transition ", didSelectDeparture, withTransistion ) )
        lastButtonTouchWasDeparture = true
    }
    
    
    
    // MARK: AirportsViewControllerDelegate Methods
    
    func airportsViewController( airportsViewController: AirportsViewController,
                                 didSelectDeparture: Bool,
                                 fromAirport: String )
    {
        if didSelectDeparture
        {
            NSLog( "%@:%@[%d] - [ %@ ][ %@ ]", description(), #function, #line, stringForBool( boolValue: didSelectDeparture ), fromAirport )
            DispatchQueue.main.async
                {
                    self.departureAirportButton.setTitle( fromAirport, for: .normal )
                    self.configureBarButtons()
                }
            
        }
        
    }
    
    
    func airportsViewController( airportsViewController: AirportsViewController,
                                 didSelectDestination: Bool,
                                 toAirport: String )
    {
        if didSelectDestination
        {
            NSLog( "%@:%@[%d] - [ %@ ][ %@ ]", description(), #function, #line, stringForBool( boolValue: didSelectDestination ), toAirport )
            DispatchQueue.main.async
                {
                    self.destinationAirportButton.setTitle( toAirport, for: .normal )
                    self.configureBarButtons()
                }
            
        }
        
    }
    
    
    
    // MARK: HeadingViewControllerDelegate Methods
    
    func headingViewController( sender: HeadingViewController, didSelectHeading: String )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: String( format: "fly heading of %@ ", didSelectHeading ) )
    }
    
    
    
    // MARK: NSNotification Methods
    
    @objc func keyboardWillHide( notification: NSNotification )
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        keyboardIsVisible = false
        configureAcceleratorButtons()
    }
    
    
    @objc func keyboardWillShow( notification: NSNotification )
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        keyboardIsVisible = true
        configureAcceleratorButtons()
    }
    
    
    @objc func showSplashScreen( notification: NSNotification )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_WELCOME )

        splitViewController?.present( myViewController,
                                      animated: true,
                                      completion: nil )
    }
    
    
    
    // MARK: SplitViewControllerDelegate Methods

    func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController ) -> UIInterfaceOrientationMask
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        return UIInterfaceOrientationMask.all
    }

    
        // Responding to Display Mode Changes
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode )
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        DispatchQueue.main.async
            {
                self.configureAcceleratorButtons()
            }
        
    }

    
    
    // MARK: Target/Action Methods - Controls above accelerators

    @IBAction func aircraftButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_AIRCRAFT )
        
        present( viewController: myViewController,
                 inNavigationController: true,
                 fromButton: sender )
    }
    
    
    @IBAction func clearBarButtonItemTouched(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        resetControls()
    }
    
    
    @IBAction func deleteWordButtonTouched(_ sender: UIButton )
    {
        if myRouteTextView.text.count <= 2
        {
            sender.isHidden      = true
            myRouteTextView.text = ""
            return
        }
        
        var     indexOfSpace = GlobalConstants.NO_SELECTION
        
        for index in ( 1...( myRouteTextView.text.count - 2 ) ).reversed()
        {
            let     offset = myRouteTextView.text.index( myRouteTextView.text.startIndex,
                                                         offsetBy: index )
            if " " == myRouteTextView.text[offset]
            {
                indexOfSpace = index
                break
            }
            
        }
        
        if GlobalConstants.NO_SELECTION == indexOfSpace
        {
            myRouteTextView.text = ""
        }
        else
        {
            let mySubstring = myRouteTextView.text.prefix( indexOfSpace )
            
            myRouteTextView.text = String.init( mySubstring )
        }
        
        routeBeforeDepartureAdded = myRouteTextView.text;
        
        sender.isHidden = ( 0 == myRouteTextView.text.count );
    }
    
    
    @IBAction func departureAirportButtonTouched(_ sender: UIButton)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        airportsMode = AirportModes.eShowDeparture
        
        let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_AIRPORTS )
        
        present( viewController: myViewController,
                 inNavigationController: true,
                 fromButton: sender )
    }
    
    
    @IBAction func destinationAirportButtonTouched(_ sender: UIButton)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        airportsMode = AirportModes.eShowDestination
        
        let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_AIRPORTS )
        
        present( viewController: myViewController,
                 inNavigationController: true,
                 fromButton: sender )
    }
    
    
    @IBAction func headingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_HEADING )
        
        present( viewController: myViewController,
                 inNavigationController: false,
                 fromButton: sender )
    }
    
    
    @IBAction func saveBarButtonItemTouched(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if !dataInAllFields()
        {
            return
        }
        
        var     clearance               = [String].init()
        var     recentClearancesArray   = [[String]].init()
        let     formattedDate           = DateFormatter.localizedString( from: Date.init(),
                                                                         dateStyle: DateFormatter.Style.short,
                                                                         timeStyle: DateFormatter.Style.short )
        
        clearance.append( departureAirportButton.title( for: .normal )! )
        clearance.append( departureFrequencyTextField.text! )
        clearance.append( destinationAirportButton.title( for: .normal )! )
        clearance.append( expectedAltitudeTextField.text! )
        clearance.append( initialAltitudeTextField.text! )
        clearance.append( myRouteTextView.text! )
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
        
        NotificationCenter.default.post( name: NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_UPDATE_RECENTS ), object: self )
 
        configureBarButtons()
        
        presentAlert( title: "Save Clearance", message: "This clearance has been saved and is viewable on the Recents tab." )
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
    
    

    // MARK: Target/Action Methods - Accelerators
    
    @IBAction func asFiledButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "then as filed " )
    }
    
    
    @IBAction func clearanceVoidTimeButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "clearance void time of " )
    }
    
    
    @IBAction func clearedToButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "cleared to " )
    }
    
    
    @IBAction func climbButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "climb to " )
    }
    
    
    @IBAction func crossButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "cross " )
    }
    
    @IBAction func departureButtonTouched(_ sender: UIButton )
    {
        let         buttonEnabled  = ( ( GlobalConstants.EMPTY_STRING != departureAirportButton  .title( for: .normal ) ) &&
                                       ( GlobalConstants.EMPTY_STRING != destinationAirportButton.title( for: .normal ) ) &&
                                       ( GlobalConstants.EMPTY_STRING != tailNumberButton        .title( for: .normal ) ) )
        if buttonEnabled
        {
            NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
            let         myViewController: UIViewController = viewControllerWithStoryboardId( storyboardId: STORYBOARD_ID_AIRPORT_DEPARTURES )
            
            present( viewController: myViewController, inNavigationController: true, fromButton: sender )
        }
        else
        {
            NSLog( "%@:%@[%d] - %@", description(), #function, #line, "INPUT ERROR:  You must select the aircraft and departure and destination airports before selecting a departure procedure" )
            presentAlert( title: "Departure Procedure Button", message: "You must select the aircraft and departure and destination airports before selecting a departure procedure" )
        }
        
    }
    
    
    @IBAction func descendButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "descend to " )
    }
    
    
    @IBAction func destinationButtonTouched(_ sender: UIButton )
    {
        if GlobalConstants.EMPTY_STRING != destinationAirportButton.title( for: .normal )
        {
            NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
            addTextToRoute( additionalText: String( format: "%@ ", destinationAirportButton.title( for: .normal )! ) )
        }
        else
        {
            NSLog( "%@:%@[%d] - %@", description(), #function, #line, "INPUT ERROR:  Select the destination airport before using this button" )
            presentAlert( title: "Destination Button", message: "Select the destination airport before using this button" )
        }

    }
    
    
    @IBAction func directToButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "direct to " )
    }
    
    
    @IBAction func dismissKeyboardButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if nil == activeTextField
        {
            myRouteTextView.resignFirstResponder()
        }

        configureViewOnEndOfEditing()
    }
    
    
    @IBAction func expectFurtherClearanceButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "expect further clearance in " )
    }
    
    
    @IBAction func holdButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "hold " )
    }
    
    
    @IBAction func inboundButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "inbound " )
    }
    
    
    @IBAction func interceptButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "intercept " )
    }
    
    
    @IBAction func outboundButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "outbound " )
    }
    
    
    @IBAction func procedureTurnButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "procedure turn " )
    }
    
    
    @IBAction func radarVectorsButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "expect radar vectors " )
    }
    
    
    @IBAction func reportPassingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "report passing " )
    }
    
    
    @IBAction func runwayHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "fly runway heading " )
    }
    
    
    @IBAction func turnLeftButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "turn left to " )
    }
    
    
    @IBAction func turnRightButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "turn right to" )
    }
    
    

    // MARK: Timer Methods
    
    @objc func timerFired( timer: Timer )
    {
        configureBarButtons()
    }

    
    
    // MARK: WelcomeViewControllerDelegate Methods
    
    func dismissWelcomeViewController( welcomeVC: WelcomeViewController )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        splitViewController?.dismiss( animated: true, completion: nil )
    }
    
    
    
    // MARK: UIPopoverPresentationControllerDelegate Methods
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    
    
    // MARK: Utility Methods
    
    func addTextToRoute( additionalText: String )
    {
        let     stringLength = myRouteTextView.text.count
        
        if 0 != stringLength
        {
            if ( " " != ( myRouteTextView.text as NSString ).substring( to: stringLength - 1 ) )
            {
                myRouteTextView.text = myRouteTextView.text + " "
            }
            
        }
        
        myRouteTextView.text = myRouteTextView.text + additionalText
        currentDeleteButton.isHidden = false
        lastButtonTouchWasDeparture  = false
        
        let overflow = myRouteTextView.contentSize.height - myRouteTextView.frame.size.height
        
        // Although we'll let the user scroll around in our text view,
        // we want the last line to always be displayed after he hits a soft-key
        if  0.0 < overflow
        {
            let lowerPart = CGRect( x: 0,
                                    y: overflow,
                                    width:  myRouteTextView.frame.size.width,
                                    height: myRouteTextView.frame.size.height )
            
            myRouteTextView.scrollRectToVisible( lowerPart, animated: false )
        }
        
    }
    
    
    func adjustAltitude( field: UITextField )
    {
//        NSLog( "%@:%@[%d] - %@", description(), #function, #line, ( ( field == initialAltitudeTextField ) ? "initial" : "expected" ) )
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
    
    
    func configureAcceleratorButtons()
    {
        let     orientation       = UIApplication.shared.statusBarOrientation
        let     inPortraitModeNow = ( ( UIInterfaceOrientation.portrait == orientation ) || ( UIInterfaceOrientation.portraitUpsideDown == orientation ) )
        let     useBigButtons     = ( inPortraitModeNow || ( !inPortraitModeNow && !keyboardIsVisible ) )
//        NSLog( "%@:%@[%d] - inPortraitModeNow[ %@ ]  useBigButtons[ %@ ]", description(), #function, #line, stringForBool( boolValue: inPortraitModeNow ), stringForBool( boolValue: useBigButtons ) )

        smallAsFiledButton                .isHidden = useBigButtons
        smallClearanceVoidTimeButton      .isHidden = useBigButtons
        smallClearedToButton              .isHidden = useBigButtons
        smallClimbButton                  .isHidden = useBigButtons
        smallCrossButton                  .isHidden = useBigButtons
        smallDeleteWordButton             .isHidden = ( useBigButtons || ( GlobalConstants.EMPTY_STRING == myRouteTextView.text )  )
        smallDepartureButton              .isHidden = useBigButtons
        smallDescendButton                .isHidden = useBigButtons
        smallDestinationButton            .isHidden = useBigButtons
        smallDirectToButton               .isHidden = useBigButtons
        smallDismissKeyboardButton        .isHidden = ( useBigButtons || ( !useBigButtons && !keyboardIsVisible ) )
        smallExpectFurtherClearanceButton .isHidden = useBigButtons
        smallHeadingButton                .isHidden = useBigButtons
        smallHoldButton                   .isHidden = useBigButtons
        smallInboundButton                .isHidden = useBigButtons
        smallInterceptButton              .isHidden = useBigButtons
        smallOutboundButton               .isHidden = useBigButtons
        smallProcedureTurnButton          .isHidden = useBigButtons
        smallRadarVectorsButton           .isHidden = useBigButtons
        smallReportPassingButton          .isHidden = useBigButtons
        smallRunwayHeadingButton          .isHidden = useBigButtons
        smallTurnLeftButton               .isHidden = useBigButtons
        smallTurnRightButton              .isHidden = useBigButtons
        
        bigAsFiledButton                  .isHidden = !useBigButtons
        bigClearanceVoidTimeButton        .isHidden = !useBigButtons
        bigClearedToButton                .isHidden = !useBigButtons
        bigClimbButton                    .isHidden = !useBigButtons
        bigCrossButton                    .isHidden = !useBigButtons
        bigDeleteWordButton               .isHidden = ( !useBigButtons || ( GlobalConstants.EMPTY_STRING == myRouteTextView.text ) )
        bigDepartureButton                .isHidden = !useBigButtons
        bigDescendButton                  .isHidden = !useBigButtons
        bigDestinationButton              .isHidden = !useBigButtons
        bigDirectToButton                 .isHidden = !useBigButtons
        bigDismissKeyboardButton          .isHidden = ( !useBigButtons || ( useBigButtons && !keyboardIsVisible ) )
        bigExpectFurtherClearanceButton   .isHidden = !useBigButtons
        bigHeadingButton                  .isHidden = !useBigButtons
        bigHoldButton                     .isHidden = !useBigButtons
        bigInboundButton                  .isHidden = !useBigButtons
        bigInterceptButton                .isHidden = !useBigButtons
        bigOutboundButton                 .isHidden = !useBigButtons
        bigProcedureTurnButton            .isHidden = !useBigButtons
        bigRadarVectorsButton             .isHidden = !useBigButtons
        bigReportPassingButton            .isHidden = !useBigButtons
        bigRunwayHeadingButton            .isHidden = !useBigButtons
        bigTurnLeftButton                 .isHidden = !useBigButtons
        bigTurnRightButton                .isHidden = !useBigButtons
        
        currentDeleteButton = ( useBigButtons ? bigDeleteWordButton : smallDeleteWordButton )
    }
    
    
    func configureBarButtons()
    {
        let     emptyFieldsPresent = ( GlobalConstants.NO_SELECTION != firstEmptyField() )

//        NSLog( "%@:%@[%d] - %@ ", description(), #function, #line, String( format: "emptyFieldsPresent[ %@ ]", stringForBool( boolValue: emptyFieldsPresent ) ) )
        saveBarButtonItem.isEnabled = !emptyFieldsPresent
    }
    
    
    func configureViewOnEndOfEditing()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        
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
            
            activeTextField = nil
        }
        
        configureBarButtons()
    }
    
    
    func dataInAllFields() -> Bool
    {
        var emptyFieldName = String.init()
        
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
            let     errorMessage = "The " + emptyFieldName + " field cannot be left blank"
            
            NSLog( "%@:%@[%d] - %@ [ false ] - %@", description(), #function, #line, errorMessage )
            presentAlert( title: "Save Clearance Error", message: errorMessage )
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
        return "ClearedToiPadViewController"
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
        
        if ( GlobalConstants.EMPTY_STRING == myRouteTextView.text )
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
            
            myRouteTextView.text = titleForElement( itemIndex: GlobalConstants.Clearances.eRouteDescription, clearance: lastClearance! )
        }
        
    }
    
    
    func present( viewController: UIViewController,
                  inNavigationController: Bool,
                  fromButton: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if ( inNavigationController )
        {
            let     navigationController = UINavigationController.init( rootViewController: viewController )
            
            navigationController.modalPresentationStyle = .popover
            
            present( navigationController, animated: true, completion: nil )
            
            navigationController.popoverPresentationController?.delegate                 = self
            navigationController.popoverPresentationController?.permittedArrowDirections = .any
            navigationController.popoverPresentationController?.sourceRect               = fromButton.bounds
            navigationController.popoverPresentationController?.sourceView               = fromButton
        }
        else
        {
            viewController.modalPresentationStyle = .popover
            
            present( viewController, animated: true, completion: nil )
            
            viewController.popoverPresentationController?.delegate                 = self
            viewController.popoverPresentationController?.permittedArrowDirections = .any
            viewController.popoverPresentationController?.sourceRect               = fromButton.bounds
            viewController.popoverPresentationController?.sourceView               = fromButton
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
        
        myRouteTextView.text = GlobalConstants.EMPTY_STRING
    }
    
    
    func titleForElement( itemIndex: Int,
                          clearance: [String] )-> String
    {
        let     title = clearance[itemIndex]
        
        return( ( 0 != title.lengthOfBytes(using: String.Encoding.ascii ) ) ? title : String.init() )
    }
    
    
    func viewControllerWithStoryboardId( storyboardId: String ) -> UIViewController
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, storyboardId )
        let     storyboard     = UIStoryboard.init( name: "MainStoryboard_iPad", bundle: nil )
        let     viewController = storyboard.instantiateViewController( withIdentifier: storyboardId )
        
        if storyboardId == STORYBOARD_ID_AIRCRAFT
        {
            let     vc = viewController as! AircraftViewController
            
            vc.delegate     = self
            vc.fromSettings = false
        }
        else if storyboardId == STORYBOARD_ID_AIRPORTS
        {
            let     vc = viewController as! AirportsViewController
            
            vc.delegate    = self
            vc.displayMode = airportsMode
        }
        else if storyboardId == STORYBOARD_ID_AIRPORT_DEPARTURES
        {
            let     vc = viewController as! AirportDeparturesViewController

            vc.delegate                  = self
            vc.departureAirport          = departureAirportButton.title( for: .normal )
            vc.useLastDepartureSelection = lastButtonTouchWasDeparture
        }
        else if storyboardId == STORYBOARD_ID_HEADING
        {
            let     vc = viewController as! HeadingViewController
            
            vc.delegate = self
        }
        else if storyboardId == STORYBOARD_ID_WELCOME
        {
            let     vc = viewController as! WelcomeViewController
            
            vc.delegate         = self
            vc.dismissWithTimer = true
        }
        
        return viewController
    }
    
}
