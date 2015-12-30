//
//  PictureBookViewController.swift
//  PictureBook
//
//  Created by hunglun on 12/30/15.
//  Copyright © 2015 hunglun. All rights reserved.
//

import UIKit
 



var pictureStoryContent = PictureStoryContent(content:"Once upon a time there was a mother Sow who lived in an old barn with her three little Pigs. When the little pigs were old enough to be on their own, she sent them out to seek their fortune.")

class PictureBookViewController: UIViewController, UITextFieldDelegate {
    var storyContentIndex : Int!
    @IBOutlet var textField: UITextField!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var toolbar: UIToolbar!

    let textAttributes = [
        // black outline
        NSStrokeColorAttributeName : UIColor(white: 0, alpha: 1),
        NSForegroundColorAttributeName : UIColor(white: 0.5, alpha: 1),         // grey fill
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3
    ]
    
    func selectNextPage(){
        let nextController = self.storyboard!.instantiateViewControllerWithIdentifier("PictureBookViewController") as! PictureBookViewController

        nextController.storyContentIndex = self.storyContentIndex + 1
        navigationController?.pushViewController(nextController, animated: true)
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
        if storyContentIndex < pictureStoryContent.contentToListOfSublists().count - 1 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "selectNextPage")
        }else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start Over", style: .Plain, target: self, action: "startOver")
            
        }

    }
    
    func imageSearch (sender : NSObject) {
        if let sender = sender as? UIBarButtonItem where sender.title != nil {
            let urlString = "https://www.google.com/search?q=\(sender.title!)"
            if let url = NSURL (string: urlString) {
                let requestObj = NSURLRequest(URL: url)
                webView.loadRequest(requestObj)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

       
        
        textField.delegate = self
        textField.defaultTextAttributes = textAttributes
        textField.textAlignment = .Center
        textField.clearButtonMode = .WhileEditing
    
        // Create bar button on toolbar
        for word in pictureStoryContent.contentToListOfSublists()[storyContentIndex] {
            toolbar.items?.append(UIBarButtonItem(title: word, style: .Plain, target: self, action: "imageSearch:" ))
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("Text Edit End")
        if let text = textField.text {
            if let url = NSURL (string: "https://www.google.com.sg/search?q=\(text)") {
                let requestObj = NSURLRequest(URL: url)
                webView.loadRequest(requestObj)
            }
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        return true
    }

}

