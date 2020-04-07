//
//  RouteViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/6/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



protocol RouteViewControllerDelegate: class
{
    func dismissRouteViewController( sender: RouteViewController )

    func routeViewController( sender: RouteViewController,
                              enteredRoute: String )
}



class RouteViewController: UIViewController,
                           AirportDeparturesViewControllerDelegate,
                           HeadingViewControllerDelegate,
                           UITextViewDelegate
{
    let SEGUE_AIRPORT_DEPARTURES = "ShowAirportDepartures"
    let SEGUE_HEADING            = "ShowHeading"
    
    

    @IBOutlet weak var myRouteTextView:     UITextView!
    @IBOutlet weak var deleteWordButton:    UIButton!
    @IBOutlet weak var directToButton:      UIButton!
    
    weak var delegate: RouteViewControllerDelegate?

    var beginningRoute:                 String!     // Set by delegate
    var cancelRequested:                Bool!
    var departureAirport:               String!     // Set by delegate
    var destinationAirport:             String!     // Set by delegate
    var lastButtonTouchWasDeparture:    Bool!
    var routeBeforeDepartureAdded:      String!
    var segueInProgress:                Bool!

    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
        
        title = "Route"

        cancelRequested             = false
        lastButtonTouchWasDeparture = false
        segueInProgress             = false
        
        destinationAirport = destinationAirport + " "
        
        myRouteTextView.delegate = self

        configureBarButtonItems()
    }
    

    override func viewWillAppear(_ animated: Bool )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        if segueInProgress
        {
            segueInProgress = false
        }
        else
        {
            addTextToRoute( additionalText: beginningRoute )
        }
    
        deleteWordButton.isHidden = ( 0 == myRouteTextView.text.count )
    
        NotificationCenter.default.addObserver( self,
                                                selector: #selector( RouteViewController.keyboardDidShow( notification: )  ),
                                                name:     NSNotification.Name.UIKeyboardDidShow,
                                                object:   nil )
    }
    
    
    override func viewWillDisappear(_ animated: Bool )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )

        if ( !segueInProgress && !cancelRequested )
        {
            delegate?.routeViewController( sender: self, enteredRoute: myRouteTextView.text )
        }
        
        NotificationCenter.default.removeObserver( self )
    }
    
    
    override func didReceiveMemoryWarning()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: AirportDepartureViewControllerDelegate Methods
    
    func airportDeparturesViewController( airportDeparturesViewController: AirportDeparturesViewController,
                                          didSelectDeparture: String)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if lastButtonTouchWasDeparture
        {
            myRouteTextView.text = routeBeforeDepartureAdded
        }
        
        addTextToRoute( additionalText: String( format: "%@ departure ", didSelectDeparture ) )
        lastButtonTouchWasDeparture = true
    }
    
    
    func airportDeparturesViewController( airportDeparturesViewController: AirportDeparturesViewController,
                                          didSelectDeparture: String,
                                          withTransistion: String)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if lastButtonTouchWasDeparture
        {
            myRouteTextView.text = routeBeforeDepartureAdded
        }
        
        addTextToRoute( additionalText: String( format: "%@ departure %@ transition ", didSelectDeparture, withTransistion ) )
        lastButtonTouchWasDeparture = true
    }
    
    
    
    // MARK: HeadingViewControllerDelegate Methods
    
    func headingViewController( sender: HeadingViewController, didSelectHeading: String )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: String( format: "fly heading of %@ ", didSelectHeading ) )
    }
    
    
    
    // MARK: NSNotification Methods
    
    @objc func keyboardDidShow( notification: NSNotification )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        deleteWordButton.isHidden = true
    }
    
    
    
    // MARK: Target/Action Methods
    
    @IBAction func cancelBarButtonItemTouched(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        cancelRequested = true
        delegate?.dismissRouteViewController( sender: self )
    }
    
    
    @IBAction func clearBarButtonItemTouched(_ sender: UIBarButtonItem )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        lastButtonTouchWasDeparture = false
        routeBeforeDepartureAdded   = ""

        myRouteTextView.text = ""
   }
    
    
    @IBAction func deleteWordButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        if myRouteTextView.text.count <= 2
        {
            deleteWordButton.isHidden = true
            myRouteTextView.text      = ""
            return
        }
        
        var     indexOfSpace = GlobalConstants.NO_SELECTION
        
        for index in ( 1...( myRouteTextView.text.count - 2 ) ).reversed()
        {
            let     offset = myRouteTextView.text.index( myRouteTextView.text.startIndex, offsetBy: index )
            
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
        
        deleteWordButton.isHidden = ( 0 == myRouteTextView.text.count );
    }
    
    
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
    
    
    @IBAction func descendButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "descend to " )
    }
    
    
    @IBAction func destinationButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: destinationAirport )
    }
    
    
    @IBAction func directToButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "direct to " )
    }
    
    
    @IBAction func expectFurtherClearanceButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "expect further clearance in " )
    }
    
    
    @IBAction func holdButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        addTextToRoute( additionalText: "HOLD " )
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
    
    
    
    // MARK: UITextViewDelegate Methods
    
    func textView(_ textView: UITextView,
                    shouldChangeTextIn range: NSRange,
                    replacementText text: String) -> Bool
    {
        var     shouldChangeText = true
    
        if text == "\n"
        {
            deleteWordButton.isHidden = ( 0 == myRouteTextView.text.count )
            textView.resignFirstResponder()
    
            shouldChangeText = false
        }
    
        return shouldChangeText;
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
        deleteWordButton.isHidden   = false
        lastButtonTouchWasDeparture = false
    
        let     overflow = myRouteTextView.contentSize.height - myRouteTextView.frame.size.height
        
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
    
    
    func configureBarButtonItems()
    {
        let     cancelBarButtonItem = UIBarButtonItem.init( barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector( cancelBarButtonItemTouched ) )
        let     clearBarButtonItem  = UIBarButtonItem.init( title: "Clear", style: UIBarButtonItemStyle.plain, target: self, action: #selector( clearBarButtonItemTouched  ) )

        navigationItem.rightBarButtonItems = [clearBarButtonItem, cancelBarButtonItem]
    }
    
    
    func description() -> String
    {
        return "RouteViewController"
    }
    
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? )
    {
        if segue.identifier == SEGUE_AIRPORT_DEPARTURES
        {
            let     vcDeparture: AirportDeparturesViewController = segue.destination as! AirportDeparturesViewController

            vcDeparture.delegate                  = self;
            vcDeparture.useLastDepartureSelection = lastButtonTouchWasDeparture;
            vcDeparture.departureAirport          = departureAirport;
            
            if ( !lastButtonTouchWasDeparture )
            {
                routeBeforeDepartureAdded = myRouteTextView.text;
            }
            
            segueInProgress = true
        }
            
        else if segue.identifier == SEGUE_HEADING
        {
            let     vcHeading: HeadingViewController = segue.destination as! HeadingViewController

            vcHeading.delegate = self
            segueInProgress    = true
        }
        
    }
    
}
