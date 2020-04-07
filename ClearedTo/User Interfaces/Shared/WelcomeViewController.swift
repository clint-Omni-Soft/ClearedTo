//
//  WelcomeViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/5/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit
import SpriteKit
import AVFoundation



protocol WelcomeViewControllerDelegate: class
{
    func dismissWelcomeViewController( welcomeVC: WelcomeViewController )
}



class WelcomeViewController: UIViewController
{
    let SPLASH_DURATION = 1.5
    
    

    @IBOutlet weak var splashImageView: UIImageView!
    
    weak var delegate:  WelcomeViewControllerDelegate?
    
    var     dismissWithTimer:   Bool?       // Set by delegate
    
    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        showWelcomeScreen()
    }
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillDisappear( animated )
        
        navigationController?.isNavigationBarHidden = false
        tabBarController?.tabBar.isHidden = false
    }

    
    override func didReceiveMemoryWarning()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.didReceiveMemoryWarning()
    }
    

    
    // MARK: NSTimer Methods
    
    @objc func dismissWithTimer( theTimer: Timer )
    {
        playSound( mySound: "swoosh" )
    
        theTimer.invalidate()
        delegate?.dismissWelcomeViewController( welcomeVC: self )
    }
    
    
    
    // MARK: Utility Methods
    
    func description() -> String
    {
        return "WelcomeViewController"
    }
    
    
    func showWelcomeScreen()
    {
        NSLog( "%@:%@[%d] - dismissWithTimer[ %@ ]", description(), #function, #line, stringForBool( boolValue: dismissWithTimer! ) )
        var     imageFileName = "Default"
        let     screenBounds  = UIScreen.main.bounds
        let     screenScale   = UIScreen.main.scale
        
        if dismissWithTimer!
        {
            let deviceOrientation = UIDevice.current.orientation
            
            // OK, we are showing the Splash Screen (Full Screen)
            Timer.scheduledTimer( timeInterval: SPLASH_DURATION,
                                  target: self,
                                  selector: #selector( dismissWithTimer( theTimer: ) ),
                                  userInfo: nil,
                                  repeats: false )
            
            if .pad == UIDevice.current.userInterfaceIdiom
            {
                // Load the image that is appropriate for this orientation on an iPad
                if ( ( UIDeviceOrientation.portrait == deviceOrientation ) || ( UIDeviceOrientation.portraitUpsideDown == deviceOrientation ) )
                {
                    imageFileName = ( ( 2.0 == screenScale ) ? "Default-Portrait@2x~ipad" : "Default-Portrait~ipad" );
                }
                else
                {
                    imageFileName = ( ( 2.0 == screenScale ) ? "Default-Landscape@2x~ipad" : "Default-Landscape~ipad" );
                }
                
            }
            else  // This is an iPhone and we only support portrait
            {
                if ( ( 320 == screenBounds.size.width  ) && ( 480 == screenBounds.size.height ) )
                {
                    imageFileName = ( ( 2.0 == screenScale) ? "Default@2x" : "Default" );
                }
                else if ( ( 320 == screenBounds.size.width  ) && ( 568 == screenBounds.size.height ) && ( 2.0 == screenScale ) )
                {
                    imageFileName = "Default-568h@2x";
                }
                
            }
            
            navigationController?.isNavigationBarHidden = true
            tabBarController?.tabBar.isHidden = true

            splashImageView.frame = screenBounds
        }
        else  // This is for the About view which is either on an iPhone or in the master view of the splitview and we treat both the same
        {
            if ( ( 320 == screenBounds.size.width  ) && ( 480 == screenBounds.size.height ) )   // iPhone 4 and earlier
            {
                imageFileName = ( ( 2.0 == screenScale) ? "Default@2x" : "Default" );
            }
            else if ( ( 320 == screenBounds.size.width  ) && ( 568 == screenBounds.size.height ) && ( 2.0 == screenScale ) )
            {
                imageFileName = "Default-568h@2x";    // iPhone 5
            }
            else  // iPad
            {
                imageFileName = ( ( 2.0 == screenScale) ? "Default@2x" : "Default" );
            }
            
        }
        
        let     imageFilePath = Bundle.main.path( forResource: imageFileName, ofType: "png" )
        let     imageFileURL  = URL.init( fileURLWithPath: imageFilePath! )
        var     myImageData: Data!
        
        do
        {
            try myImageData = Data.init( contentsOf: imageFileURL, options: Data.ReadingOptions.uncached )
                splashImageView.image = UIImage.init( data: myImageData )
        }
        catch
        {
            NSLog( "%@:%@[%d] - %@", description(), #function, #line, error.localizedDescription )
        }
        
    }

}
