//
//  Item.swift
//  Todoey
//
//  Created by Alex on 23/12/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdAt: Date = Date()
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
