//
//  ExtArray.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/8/18.
//  Copyright © 2022 Omni-Soft, Inc. All rights reserved.
//


import UIKit


    // This class is basically a smart array object that knows how to load itself from UserDefaults
    // and then provide the caller the ability to manipulate what is in the array and notify others when it changes


class ExtArray: NSObject
{
    var arrayName:                  String!
    var indexOfSelectedElement:     Int!
    var minimumLength:              Int!
    var myArray:                    [String]!
    var notificationsKey:           String!
    var userDefaultsKey:            String!

    
    
    // MARK: Initializaton Methods

    func initWithName( nameOfArray: String,
                       lengthMinimum: Int,
                       keyForNotification: String,
                       keyForUserDefault: String )
    {
        arrayName               = nameOfArray
        indexOfSelectedElement  = GlobalConstants.NO_SELECTION
        minimumLength           = lengthMinimum
        myArray                 = UserDefaults.standard.array( forKey: keyForUserDefault ) as? [String]
        notificationsKey        = keyForNotification
        userDefaultsKey         = keyForUserDefault
    }
    
    
    
    // MARK: Accessor Methods
    
    func addString( newString: String )
    {
        var     newArray = [String]()
        
        if nil == myArray
        {
            newArray.append( newString )
            indexOfSelectedElement = 0
            
            myArray = Array.init( newArray )
        }
        else    // We assume that the caller checked for duplicates before we got here, so we can just append it and move on
        {
            newArray.append( contentsOf: myArray )
            newArray.append( newString )
            
            newArray = newArray.sorted()
            
            for index in 0..<newArray.count
            {
                if newString == newArray[index]
                {
                    indexOfSelectedElement = index
                    break
                }
                
            }
            
            myArray = Array.init( newArray )
        }
        
        UserDefaults.standard.removeObject(  forKey: userDefaultsKey )
        UserDefaults.standard.set( newArray, forKey: userDefaultsKey )
        UserDefaults.standard.synchronize()
        
        if notificationsKey != GlobalConstants.EMPTY_STRING
        {
            NotificationCenter.default.post( name: NSNotification.Name( rawValue: notificationsKey ), object: self )
        }

    }
    

    func deleteStringAtIndex( index: Int )
    {
        UserDefaults.standard.removeObject( forKey: userDefaultsKey  )
        
        if ( nil == myArray )
        {
            NSLog( "%@:%@[%d] - %@", description(), #function, #line, "Ignoring ... myArray is nil!" )
        }
        else if 1 == myArray.count
        {
            myArray = nil
            indexOfSelectedElement = GlobalConstants.NO_SELECTION
        }
        else
        {
            var     newArray:[String] = Array.init( myArray )
            var     selectedElementName: String!
            
            
            if index == indexOfSelectedElement
            {
                indexOfSelectedElement = GlobalConstants.NO_SELECTION
            }
            else
            {
                if GlobalConstants.NO_SELECTION != indexOfSelectedElement
                {
                    selectedElementName = myArray[indexOfSelectedElement]
                }

            }
            
            newArray.remove( at: index )
            myArray = Array.init( newArray )
            
            UserDefaults.standard.set( newArray, forKey: userDefaultsKey )
            
            if nil != selectedElementName
            {
                for index in 0..<myArray.count
                {
                    if selectedElementName == myArray[index]
                    {
                        indexOfSelectedElement = index
                        break
                    }
                    
                }
                
            }
            
        }
        
        UserDefaults.standard.synchronize()
        
        if notificationsKey != GlobalConstants.EMPTY_STRING
        {
            NotificationCenter.default.post( name: NSNotification.Name( rawValue: notificationsKey ), object: self )
        }
        
    }
    

    func description() -> String
    {
        return "ExtArray"
    }
    
    
    func elementAt( index: Int ) -> String
    {
        return myArray[index]
    }
    
    
    func elementIsValid( elementName: String ) -> String?
    {
        var     errorMsg:       String!
        let     range = elementName.rangeOfCharacter( from: CharacterSet.init( charactersIn: " ~`!@#$%^&*()-_=+|}{[]:;'<>?/.,\"\\" ) )
        
        if minimumLength > elementName.count
        {
            errorMsg = String( format: "%@ name must be at least %d characters long!", arrayName, minimumLength )
        }
        else if ( nil != range )
        {
            errorMsg = String( format: "Invalid character!  %@ name can only have Alpha and Numeric characters.", arrayName )
        }
        else
        {
            if nil != myArray
            {
                for element in myArray
                {
                    if element == elementName
                    {
                        errorMsg = String( format: "'%@' is already in the list!  Try again", arrayName )
                        break
                    }
                    
                }
                
            }
            
        }
        
        if ( nil == errorMsg )
        {
//            NSLog( "%@:%@[%d] - %@ is Valid", description(), #function, #line, elementName )
        }
        else
        {
            NSLog( "%@:%@[%d] -  ERROR: %@", description(), #function, #line, errorMsg )
            playSound( mySound: "boing3" )
        }
        
        return errorMsg
    }
    
    
    func elementWasSelected() -> Bool
    {
        return ( indexOfSelectedElement != GlobalConstants.NO_SELECTION )
    }
    
    
    func numberOfElements() -> Int
    {
        return ( ( nil == myArray ) ? 0 : myArray.count )
    }
    
    
    func reload()
    {
        myArray = UserDefaults.standard.array( forKey: userDefaultsKey ) as? [String]
    }
    
    
    func selectedElement() -> String
    {
        return myArray[indexOfSelectedElement]
    }

    
    func selectElementWithName( elementName: String )
    {
        if nil != myArray
        {
            for index in 0..<myArray.count
            {
                if elementName == myArray[index]
                {
                    indexOfSelectedElement = index
                    break
                }
                
            }
            
        }
        
    }
    
}
