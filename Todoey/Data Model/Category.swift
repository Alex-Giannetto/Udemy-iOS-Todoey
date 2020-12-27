//
//  Category.swift
//  Todoey
//
//  Created by Alex on 23/12/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class Category: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var color: String = UIColor.randomFlat().hexValue()
    let items = List<Item>()
}
