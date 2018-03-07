//
//  HeadingViewController.swift
//  ClearedTo
//
//  Created by Clint Shank on 2/6/18.
//  Copyright © 2018 Omni-Soft, Inc. All rights reserved.
//


import UIKit



protocol HeadingViewControllerDelegate: class
{
    func headingViewController( sender: HeadingViewController,
                                didSelectHeading: String )
}



class HeadingViewController: UIViewController
{

    @IBOutlet weak var  headingLabel:    UILabel!
    @IBOutlet weak var  sliderBar:       UISlider!
    
    weak var delegate: HeadingViewControllerDelegate?
    
    var     userDidSetHeading:  Bool!
    
    
    
    // MARK: UIViewController Lifecycle Methods
    
    override func viewDidLoad()
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewDidLoad()
        
        title = "Heading"
        preferredContentSize = CGSize( width: 320, height: 300 )
    }
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        super.viewWillAppear( animated )
        
        userDidSetHeading = false
        setHeadingLabelFromSliderBar()
    }

    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewWillAppear( animated )

        if userDidSetHeading
        {
            NSLog( "%@:%@[%d] - userDidSetHeading[ %@ ]", description(), #function, #line, headingLabel.text! )
            delegate?.headingViewController(sender: self, didSelectHeading: headingLabel.text! )
        }
        else
        {
            NSLog( "%@:%@[%d] - %@", description(), #function, #line, "no changes" )
        }
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
    }
    


    // MARK: Target/Action Methods
    
    @IBAction func northWestHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "315", newHeading: 315.0 )
    }
    
    
    @IBAction func northHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "360", newHeading: 360.0 )
    }
    
    
    @IBAction func northEastHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "045", newHeading: 45.0 )
    }
    
    
    @IBAction func westHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "270", newHeading: 270.0 )
    }
    
    
    @IBAction func eastHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "090", newHeading: 90.0 )
    }
    
    
    @IBAction func southWestHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "225", newHeading: 225.0 )
    }
    
    
    @IBAction func southHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "180", newHeading: 180.0 )
   }
    
    
    @IBAction func southEastHeadingButtonTouched(_ sender: UIButton )
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelText( newText: "135", newHeading: 135.0 )
    }
    
    
    @IBAction func sliderValueChanged(_ sender: UISlider)
    {
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, "" )
        setHeadingLabelFromSliderBar()
    }
    
    
    // Utility Methods

    func description() -> String
    {
        return "HeadingViewController"
    }


    func setHeadingLabelFromSliderBar()
    {
        let     roundedValue: Int = Int( sliderBar.value / 10.0 )
        
        
        headingLabel.text = String( format: "%03d", (10 * roundedValue) )
        
        userDidSetHeading = true
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, headingLabel.text! )
    }

    
    func setHeadingLabelText( newText: String, newHeading: Float )
    {
        headingLabel.text = newText
        sliderBar.setValue( newHeading, animated: true )
        
        userDidSetHeading = true
        NSLog( "%@:%@[%d] - %@", description(), #function, #line, headingLabel.text! )
  }
    
    
    
    
    
    
    
    
    
}
