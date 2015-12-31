//
//  PictureBookModel.swift
//  PictureBook
//
//  Created by hunglun on 12/30/15.
//  Copyright © 2015 hunglun. All rights reserved.
//

import Foundation

struct PictureStoryContent {
    var content : String
    init(content: String){
        self.content=content.stringByReplacingOccurrencesOfString("\n", withString: " ")
    }
    func contentToListOfSublists () -> [[String]]{
        if content == "" {
            return []
        }
        let listsOfWords = content.componentsSeparatedByString(" ")
        var listOfSublists : [[String]] = []
        var sublist : [String] = []
        
        var count = 0
        for word in listsOfWords {
            count += word.characters.count
            // restrict 28 letters per view.
            if count < 28 {
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
