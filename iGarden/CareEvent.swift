//
//  CareEvent.swift
//  iGarden
//

import Foundation
import SwiftData

enum CareEventType: String, Codable, CaseIterable, Identifiable {
    case watering = "Vanning"
    case fertilizing = "Gjødsling"
    case repotting = "Ompotting"
    case pruning = "Beskjæring"

    var id: String { rawValue }

    /// Råverdien er lagringsformat og må ikke endres; visningen lokaliseres her.
    var displayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }

    var icon: String {
        switch self {
        case .watering: "drop.fill"
        case .fertilizing: "leaf.fill"
        case .repotting: "arrow.triangle.2.circlepath"
        case .pruning: "scissors"
        }
    }
}

@Model
final class CareEvent {
    var type: CareEventType
    var date: Date
    var note: String
    var plant: Plant?

    init(type: CareEventType, date: Date = .now, note: String = "") {
        self.type = type
        self.date = date
        self.note = note
    }
}
