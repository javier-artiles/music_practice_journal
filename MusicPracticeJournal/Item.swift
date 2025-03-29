//
//  Item.swift
//  MusicPracticeJournal
//
//  Created by Javier Artiles on 3/29/25.
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
