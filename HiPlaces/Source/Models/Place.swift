//
//  PlaceModel.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 20.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import Foundation
import RealmSwift

class Place {
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var image: Data?
    
    init(name: String, location: String?, type: String?, image: Data?) {
        self.name = name
        self.location = location
        self.type = type
        self.image = image
    }
}
