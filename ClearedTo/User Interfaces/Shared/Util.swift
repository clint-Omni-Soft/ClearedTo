//
//  Util.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/15/18.
//  Copyright © 2022 Omni-Soft, Inc. All rights reserved.
//


import Foundation
import AudioToolbox



func playSound( mySound: String )
{
    if let soundUrl = Bundle.main.url( forResource: mySound, withExtension: "wav" )
    {
        var     soundId: SystemSoundID = 0
        
        AudioServicesCreateSystemSoundID( soundUrl as CFURL, &soundId )
        
        AudioServicesAddSystemSoundCompletion( soundId,
                                               nil,
                                               nil,
                                               {
                                                    ( soundId, clientData ) -> Void in
                                                
                                                    AudioServicesDisposeSystemSoundID( soundId )
                                               },
                                               nil )

        AudioServicesPlaySystemSound( soundId )
        NSLog( "playSound:%@[%d] - [ %@ ]", #function, #line, mySound )
    }
    
}


func stringForBool( boolValue: Bool ) -> String
{
    return ( boolValue ? "true" : "false" )
}



