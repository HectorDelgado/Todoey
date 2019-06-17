//
//  Category.swift
//  Todoey
//
//  Created by Hector Delgado on 6/12/19.
//  Copyright © 2019 Hector Delgado. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    let items = List<Item>()    // Describes forward relationship
}
