//
//  PictureBookViewController.swift
//  PictureBook
//
//  Created by hunglun on 12/30/15.
//  Copyright © 2015 hunglun. All rights reserved.
//

import UIKit



let baseURL = "https://api.flickr.com/services/rest/"

var urlParameterDict = [
    "method"  :"flickr.photos.search",
    "api_key" : "8ba389c3eed8a5d6329c57c0f20ef23b",
    "text": "baby+asian+elephant",
    "format": "json",
    "nojsoncallback" : "1",
    "extras":"url_m"
]

/* Helper function: Given a dictionary of parameters, convert to a string for a url */
func escapedParameters(parameters: [String : AnyObject]) -> String {
    
    var urlVars = [String]()
    
    for (key, value) in parameters {
        
        /* Make sure that it is a string value */
        let stringValue = "\(value)"
        
        /* Escape it */
        let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        /* Append it */
        urlVars += [key + "=" + "\(escapedValue!)"]
        
    }
    
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
}

func createURLString(baseURL : String, parameters : [String : String]) -> String{
    return baseURL + escapedParameters(parameters)
}

class PictureBookViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    var storyContentIndex : Int!
    var pictureStoryContent : PictureStoryContent!
    @IBOutlet var textField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var flowLayout : UICollectionViewFlowLayout!

    @IBOutlet var collectionView: UICollectionView!
    let textAttributes = [
        // black outline
        NSStrokeColorAttributeName : UIColor(white: 0, alpha: 1),
        NSForegroundColorAttributeName : UIColor(white: 0.5, alpha: 1),         // grey fill
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)!,
        NSStrokeWidthAttributeName : -3
    ]
    
    func loadImage(text : String) {
        
        // create URL
        let escapedPhrase = text.componentsSeparatedByString(" ").joinWithSeparator("+")
        urlParameterDict["text"] = escapedPhrase
        let urlString = createURLString(baseURL, parameters: urlParameterDict)
        print("URL String: \(urlString)\n")
        let urlRequest = NSURLRequest(URL: NSURL(string: urlString)!)
        // create session
        let session = NSURLSession.sharedSession()
        // define completion handler
        let task = session.dataTaskWithRequest(urlRequest){ (data,response,error) in
            if error == nil {
                //                print("Data: \(data)")
                do {
                    if let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary {
                        if let photos = parsedResult["photos"]?["photo"] as? NSArray  {
                            if photos.count == 0 {
                                self.imageView.image = nil
                            }else {
                                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photos.count)))
                                let imageURL = photos[randomPhotoIndex]["url_m"]
                                print(imageURL)
                                dispatch_async( dispatch_get_main_queue()){
                                    
                                    if let imageURLString = photos[randomPhotoIndex]["url_m"] as? String ,
                                        imageURL = NSURL(string:imageURLString),
                                        data = NSData(contentsOfURL: imageURL) {
                                            self.imageView.image = UIImage(data: data)
                                    }
                                }
                                
                                
                            }
                        }
                    }
                }catch{
                    print("data is not json")
                }
                
            }else{
                print("error:\(error)")
            }
        }
        // resume task
        task.resume()
    }

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
        
        flowLayout.minimumInteritemSpacing = 0

        
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
            if let text = sender.title?.stringByReplacingOccurrencesOfString("\"", withString: "") {
                loadImage(text)
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    // It is distracting to show random image at the start of each page.
/*        let words = pictureStoryContent.contentToListOfSublists()[storyContentIndex]
        if words.count > 0 {
            loadImage(words[Int(arc4random_uniform(UInt32(words.count)))])
        }
  */      textField.delegate = self
        textField.defaultTextAttributes = textAttributes
        textField.textAlignment = .Center
        textField.clearButtonMode = .WhileEditing
    
    }
    


    override func viewWillDisappear(animated: Bool) {
        unsubscribeToKeyboardNotifications()
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
            loadImage(text)
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
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PictureBookCollectionViewCell
        if let text = cell.storyContentLabel.text {
            // the presence of opening quotation mark causes url to be invalid
            let word = text.stringByReplacingOccurrencesOfString("\"", withString: "")
            loadImage(word)
            
        }

        
    }
    
    func collectionView(tableView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return pictureStoryContent.contentToListOfSublists()[storyContentIndex].count
    }


    func collectionView(tableView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier("PictureBookCollectionViewCell", forIndexPath: indexPath) as! PictureBookCollectionViewCell
        
        let word = pictureStoryContent.contentToListOfSublists()[storyContentIndex][indexPath.row]
        
        cell.storyContentLabel.text = word
        cell.storyContentLabel.sizeToFit()
        

        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        var word = pictureStoryContent.contentToListOfSublists()[storyContentIndex][indexPath.row] as NSString
        word = "\(word)A"
        let wordTextAttributes = [
            NSFontAttributeName : UIFont(name: "HelveticaNeue", size: 25)!,
        ]
        var size = word.sizeWithAttributes(wordTextAttributes)
        size.height = size.height * 1.3
        return size
        
        
    }
    
}

