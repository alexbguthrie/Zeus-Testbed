//
//  Item.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/19/25.
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
