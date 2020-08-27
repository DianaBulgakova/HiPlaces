//
//  ModelManager.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 20.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import Foundation
import RealmSwift

enum ModelManager {
    
    static let realm = try? Realm()
    
    static func saveObject(_ place: Place) {
        try? realm?.write {
            realm?.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try? realm?.write {
            realm?.delete(place)
        }
    }
}

