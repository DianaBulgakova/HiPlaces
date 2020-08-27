//
//  Place.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 20.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import Foundation
import RealmSwift

final class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var image: Data?
    @objc dynamic var rating = 0
    @objc dynamic var date = Date()
    
    convenience init(name: String, location: String?, type: String?, image: Data?, rating: Int, date: Date) {
        self.init()

        self.name = name
        self.location = location
        self.type = type
        self.image = image
        self.rating = rating
        self.date = date
    }
}
