//
//  PictureBookViewController.swift
//  PictureBook
//
//  Created by hunglun on 12/30/15.
//  Copyright © 2015 hunglun. All rights reserved.
//

import UIKit

let searchEngine = "https://www.bing.com/images/search?q="

class PictureBookViewController: UIViewController, UITextFieldDelegate {
    var storyContentIndex : Int!
    var pictureStoryContent : PictureStoryContent!
    @IBOutlet var textField: UITextField!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var nextButton: UIButton!

    let textAttributes = [
        // black outline
        NSStrokeColorAttributeName : UIColor(white: 0, alpha: 1),
        NSForegroundColorAttributeName : UIColor(white: 0.5, alpha: 1),         // grey fill
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3
    ]
    
    func selectNextPage(){
        let nextController = self.storyboard!.instantiateViewControllerWithIdentifier("PictureBookViewController") as! PictureBookViewController
        nextController.pictureStoryContent = self.pictureStoryContent
        nextController.storyContentIndex = self.storyContentIndex + 1
        navigationController?.pushViewController(nextController, animated: false)
    }
    
    func startOver(){
        navigationController?.popToRootViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if storyContentIndex == nil {
            storyContentIndex = 0
        }
        // Create navigation button : start over and next page
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start Over", style: .Plain, target: self, action: "startOver")

        if storyContentIndex >= pictureStoryContent.contentToListOfSublists().count - 1 {
            nextButton.enabled = false
        }

    }
    
    func imageSearch (sender : NSObject) {
        if let sender = sender as? UIBarButtonItem where sender.title != nil {
            // the presence of opening quotation mark causes url to be invalid
            let title = sender.title?.stringByReplacingOccurrencesOfString("\"", withString: "")
            let urlString = "\(searchEngine)\(title!)"
            print(urlString)
            if let url = NSURL (string: urlString) {
                let requestObj = NSURLRequest(URL: url)
                webView.loadRequest(requestObj)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
       
        
        textField.delegate = self
        textField.defaultTextAttributes = textAttributes
        textField.textAlignment = .Center
        textField.clearButtonMode = .WhileEditing
    
        // Create bar button on toolbar
        for word in pictureStoryContent.contentToListOfSublists()[storyContentIndex] {
            toolbar.items?.append(UIBarButtonItem(title: word, style: .Plain, target: self, action: "imageSearch:" ))
        }
    }
    


    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
        toolbar.items?.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = textField.text?.stringByReplacingOccurrencesOfString(" ", withString: "+") {
            if let url = NSURL (string: "\(searchEngine)\(text)") {
                let requestObj = NSURLRequest(URL: url)
                webView.loadRequest(requestObj)
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        return true
    }
    
    func getKeyboardHeight(notification : NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    func keyboardWillHide(notification : NSNotification){
            view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    
    func keyboardWillShow(notification : NSNotification){
            view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func deviceWillRotate(notification : NSNotification){

        //TODO: known bug. This function gets called even when the entire screen has not rotated yet.
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            print("Orientation changes to landscape")
        } else {
            print("Orientation changes to portrait")
        }
        toolbar.items?.removeAll()
        for word in pictureStoryContent.contentToListOfSublists()[storyContentIndex] {
            toolbar.items?.append(UIBarButtonItem(title: word, style: .Plain, target: self, action: "imageSearch:" ))
        }

    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceWillRotate:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    @IBAction func next(sender: UIButton) {
        selectNextPage()
    }
    
    
}

