//
//  Item.swift
//  ShikiShiroFanClub
//
//  Created by aoiro on 2025/05/12.
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
