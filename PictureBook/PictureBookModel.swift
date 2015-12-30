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
        self.content=content
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
            // restrict 30 letters per view.
            if count < 30 {
                sublist.append(word)
                
            }else {
                listOfSublists.append(sublist)
                sublist = []
                count = 0
            }
        }
        return listOfSublists

    }
}
