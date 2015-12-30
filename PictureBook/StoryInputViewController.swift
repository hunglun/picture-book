//
//  StoryInputViewController.swift
//  PictureBook
//
//  Created by hunglun on 12/31/15.
//  Copyright © 2015 hunglun. All rights reserved.
//

import UIKit

class StoryInputViewController : UIViewController {

    @IBOutlet var textView: UITextView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let pictureBookController = segue.destinationViewController as? PictureBookViewController {
            pictureBookController.pictureStoryContent = PictureStoryContent(content: textView.text)
        }
    }

}
