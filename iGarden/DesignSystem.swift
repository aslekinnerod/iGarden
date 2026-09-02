//
//  DesignSystem.swift
//  iGarden
//
//  Design-tokens speilet fra design-system/tokens/ – én kilde til
//  sannhet for farger, radier og avstander i appen.
//  Se design-system/readme.md for hele systemet.
//

import SwiftUI

enum DS {
    /// tokens/spacing.css – radier.
    enum Radius {
        static let thumb: CGFloat = 8
        static let photo: CGFloat = 10
        static let card: CGFloat = 10
        static let button: CGFloat = 12
        static let auth: CGFloat = 8
    }

    /// tokens/spacing.css – 4-basert skala og iOS-listemål.
    enum Spacing {
        static let s1: CGFloat = 4
        static let s2: CGFloat = 8
        static let s3: CGFloat = 12
        static let s4: CGFloat = 16
        static let s5: CGFloat = 20
        static let s6: CGFloat = 24
        static let s8: CGFloat = 32
        static let hitTarget: CGFloat = 44
        static let listInset: CGFloat = 16
        static let rowGap: CGFloat = 10
    }

    /// tokens/effects.css – animasjonsvarigheter.
    enum Duration {
        static let fast: Double = 0.15
        static let base: Double = 0.25
    }
}

extension Color {
    init(dsHex hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    // MARK: Merkevaregrønt (tokens/colors.css)
    static let green900 = Color(dsHex: 0x1B4D20)
    /// Samme som AccentColor i asset-katalogen (--green-700 / --accent).
    static let green700 = Color(dsHex: 0x2E7D32)
    static let green500 = Color(dsHex: 0x4CAF50)
    static let green300 = Color(dsHex: 0xA5D6A7)
    static let green100 = Color(dsHex: 0xDCEDDC)

    // MARK: Naturals – merkevareutvidelse fra app-ikonet
    static let terracotta = Color(dsHex: 0xC97B4A)
    static let soil = Color(dsHex: 0x5C4433)
    static let sage = Color(dsHex: 0xA9C4A0)
    static let mist = Color(dsHex: 0xD7EAD1)
    static let paper = Color(dsHex: 0xFAF8F2)

    // MARK: Status og handlinger – iOS-systemfarger, som i designsystemet
    static let statusOverdue = Color.red
    static let statusDue = Color.orange
    static let statusOK = Color.green
    static let actionWater = Color.blue

    // MARK: Plassholderfyll for plantebilder (--fill-leaf)
    static let fillLeaf = Color.accentColor.opacity(0.12)
    static let fillLeafForeground = Color.accentColor.opacity(0.5)
}
