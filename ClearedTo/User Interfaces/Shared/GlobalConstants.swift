//
//  GlobalConstants.swift
//  ClearedTo
//
//  Created by Clint Shank on 1/29/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import Foundation



struct GlobalConstants
{
    struct UserDefaults
    {
        static let KEY_AIRCRAFT             = "Aircraft"
        static let KEY_AIRPORTS             = "Airports"
        static let KEY_DEPARTURES           = "Departures"
        static let KEY_LAST_DEPARTURE       = "lastDeparture"
        static let KEY_LAST_TRANSITION      = "lastTransition"
        static let KEY_RECENT_CLEARANCES    = "recentClearances"
        static let KEY_TRANSITIONS          = "Transitions"
    }
    
    static let EMPTY_STRING     = ""
    static let MAX_CLEARANCES   = 50
    static let NO_SELECTION     = -1

    struct Notifications
    {
        static let NOTIFICATION_UPDATE_AIRCRAFT      = "UpdateAircraft"
        static let NOTIFICATION_UPDATE_AIRPORTS      = "UpdateAirports"
        static let NOTIFICATION_UPDATE_DEPARTURES    = "UpdateDepartures"
        static let NOTIFICATION_UPDATE_RECENTS       = "UpdateRecents"
        static let NOTIFICATION_UPDATE_TRANSITIONS   = "UpdateTransitions"
        
        static let NOTIFICATION_SHOW_SPLASH_SCREEN   = "ShowSplashScreen"
    }
    
    // The KEY_RECENT_CLEARANCES in NSUserDefaults returns an array of arrays
    // The elements of an item in the array are stored in the following order
    struct Clearances
    {
        static let eDepartureAirport       = 0
        static let eDepartureFrequency     = 1
        static let eDestinationAirport     = 2
        static let eExpectedAltitude       = 3
        static let eInitialAltitude        = 4
        static let eRouteDescription       = 5
        static let eTailNumber             = 6
        static let eTimeToExpectedAltitude = 7
        static let eTransponderCode        = 8
        static let eDateTime               = 9
    };

}



