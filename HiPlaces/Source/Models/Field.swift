//
//  Field.swift
//  HiPlaces
//
//  Created by Диана Булгакова on 24.08.2020.
//  Copyright © 2020 Диана Булгакова. All rights reserved.
//

import Foundation

enum Field: Int, CaseIterable {
    
    case name
    case location
    case type
    
    var title: String {
        switch self {
        case .name: return "Name"
        case .location: return "Location"
        case .type: return "Type"
        }
    }
}
