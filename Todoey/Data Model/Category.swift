//
//  Category.swift
//  Todoey
//
//  Created by Alex on 23/12/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var title: String = ""
    let items = List<Item>()
}
