//
//  Item.swift
//  Todoey
//
//  Created by Alex on 22/11/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation


class Item: Codable {
    var title: String
    var done: Bool
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
    
}
