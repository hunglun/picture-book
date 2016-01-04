//
//  PictureBookModel.swift
//  PictureBook
//
//  Created by hunglun on 12/30/15.
//  Copyright © 2015 hunglun. All rights reserved.
//

import Foundation
import UIKit

struct PictureStoryContent {

    var content : String
    init(content: String){
        self.content=content.stringByReplacingOccurrencesOfString("\n", withString: " ")
    }
    func contentToListOfSublists () -> [[String]]{
        let numberOfDisplayedLetters = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) ? 80*2 : 40*2
        if content == "" {
            return []
        }
        let listsOfWords = content.componentsSeparatedByString(" ")
        var listOfSublists : [[String]] = []
        var sublist : [String] = []
        
        var count = 0
        for word in listsOfWords {
            count += word.characters.count

            if count < numberOfDisplayedLetters {
                sublist.append(word)
                
            }else {
                listOfSublists.append(sublist)
                sublist = [word]
                count = word.characters.count
            }
        }

        if count > 0 {
            listOfSublists.append(sublist)
        }
        return listOfSublists

    }
}
