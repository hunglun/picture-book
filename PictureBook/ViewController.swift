//
//  ViewController.swift
//  PictureBook
//
//  Created by hunglun on 12/30/15.
//  Copyright © 2015 hunglun. All rights reserved.
//

import UIKit
 
// restrict 30 letters per view.
var storyContent = ["There", "is", "an","old" ,"donkey", "in" ,"a" ,"far", "away" ,"farm", "village"]
    //He is too old to work. His master kicks him out."

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField: UITextField!
    @IBOutlet var webView: UIWebView!
    let textAttributes = [
        // black outline
        NSStrokeColorAttributeName : UIColor(white: 0, alpha: 1),
        NSForegroundColorAttributeName : UIColor(white: 0.5, alpha: 1),         // grey fill
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3
    ]
    

    @IBOutlet var toolbar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        
        //TODO: create bar button on toolbar
        for word in storyContent {
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

