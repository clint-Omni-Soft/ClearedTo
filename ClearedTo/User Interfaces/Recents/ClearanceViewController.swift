//
//  ClearanceViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/7/18.
//  Copyright © 2022 Omni-Soft, Inc. All rights reserved.
//


import UIKit



class ClearanceViewController: UIViewController
{

    @IBOutlet weak var aircraftLabel:               UILabel!
    @IBOutlet weak var dateLabel:                   UILabel!
    @IBOutlet weak var departureLabel:              UILabel!
    @IBOutlet weak var departureFrequencyLabel:     UILabel!
    @IBOutlet weak var destinationLabel:            UILabel!
    @IBOutlet weak var expectedAltitudeLabel:       UILabel!
    @IBOutlet weak var initialAltitudeLabel:        UILabel!
    @IBOutlet weak var routeTextView:               UITextView!
    @IBOutlet weak var timeToExpectedAltitudeLabel: UILabel!
    @IBOutlet weak var transponderCodeLabel:        UILabel!
    
    var selectedClearance: Int!         // Set by caller
    
    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        if let object = UserDefaults.standard.object( forKey: GlobalConstants.UserDefaults.KEY_RECENT_CLEARANCES )
        {
            let     recentClearancesArray = [[String]].init( object as! [[String]] )
            let     clearance             = recentClearancesArray[ selectedClearance ]
            
            aircraftLabel               .text = clearance[GlobalConstants.Clearances.eTailNumber            ]
            dateLabel                   .text = clearance[GlobalConstants.Clearances.eDateTime              ]
            departureLabel              .text = clearance[GlobalConstants.Clearances.eDepartureAirport      ]
            departureFrequencyLabel     .text = clearance[GlobalConstants.Clearances.eDepartureFrequency    ]
            destinationLabel            .text = clearance[GlobalConstants.Clearances.eDestinationAirport    ]
            expectedAltitudeLabel       .text = clearance[GlobalConstants.Clearances.eExpectedAltitude      ]
            initialAltitudeLabel        .text = clearance[GlobalConstants.Clearances.eInitialAltitude       ]
            routeTextView               .text = clearance[GlobalConstants.Clearances.eRouteDescription      ]
            timeToExpectedAltitudeLabel .text = clearance[GlobalConstants.Clearances.eTimeToExpectedAltitude]
            transponderCodeLabel        .text = clearance[GlobalConstants.Clearances.eTransponderCode       ]
            
            title = String( format: "%@ - %@", departureLabel.text!, destinationLabel.text! )
        }

    }

    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
    }
    
    
    
    // MARK: Utility Methods
    
    func description() -> String
    {
        return "ClearanceViewController"
    }

}
