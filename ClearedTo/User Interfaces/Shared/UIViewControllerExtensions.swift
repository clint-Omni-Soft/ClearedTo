//
//  UIViewControllerExtensionsViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 3/1/18.
//  Copyright © 2022 Omni-Soft, Inc. All rights reserved.
//


import UIKit



extension UIViewController
{
    func presentAlert( title: String, message: String )
    {
        NSLog( "presentAlert: [ %@ ][ %@ ]", title, message )
        let     alert    = UIAlertController.init( title: title, message: message, preferredStyle: .alert )
        let     okAction = UIAlertAction.init( title: "OK", style: .default, handler: nil )
        
        alert.addAction( okAction )
        
        present( alert, animated: true, completion: nil )
    }
    
}




