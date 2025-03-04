//
//  Item.swift
//  CaseBriefer
//
//  Created by Kevin Keller on 3/4/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
