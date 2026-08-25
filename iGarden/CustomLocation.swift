//
//  CustomLocation.swift
//  iGarden
//

import Foundation
import SwiftData

/// En plassering brukeren har lagt inn selv. Finnes det egne plasseringer,
/// vises bare disse i valglisten – ellers vises den innebygde listen.
@Model
final class CustomLocation {
    var name: String
    var createdAt: Date

    init(name: String, createdAt: Date = .now) {
        self.name = name
        self.createdAt = createdAt
    }
}
