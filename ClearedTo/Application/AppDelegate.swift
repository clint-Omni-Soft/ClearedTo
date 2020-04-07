//
//  AppDelegate.swift
//  ClearedTo
//
//  Created by Clint Shank on 1/26/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool
    {
        // Override point for customization after application launch.
        NSLog( "%@:%@[%d] - %@", self.description(), #function, #line, "" )
        return true
    }

    func applicationWillResignActive(_ application: UIApplication )
    {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        NSLog( "%@:%@[%d] - %@", self.description(), #function, #line, "" )
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }

    func applicationDidEnterBackground(_ application: UIApplication )
    {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information
        // to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NSLog( "%@:%@[%d] - %@", self.description(), #function, #line, "" )
    }

    func applicationWillEnterForeground(_ application: UIApplication )
    {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        NSLog( "%@:%@[%d] - %@", self.description(), #function, #line, "" )
    }

    func applicationDidBecomeActive(_ application: UIApplication )
    {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
            // The only way we can give ourselves enough time to get the first device orientation notification before we show the splash screen is to push
            // the posting of NOTIFICATION_SHOW_SPLASH_SCREEN onto the next run loop
        DispatchQueue.main.async
        {
            NSLog( "%@:%@[%d] - %@", self.description(), #function, #line, "" )
            NotificationCenter.default.post( name: NSNotification.Name( rawValue: GlobalConstants.Notifications.NOTIFICATION_SHOW_SPLASH_SCREEN ), object: self )
        }

    }

    func applicationWillTerminate(_ application: UIApplication )
    {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSLog( "%@:%@[%d] - %@", self.description(), #function, #line, "" )
    }

    
    
    // MARK: Utility Methods
    
    func description() -> String
    {
        return "AppDelegate"
    }
}

