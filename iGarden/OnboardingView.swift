//
//  OnboardingView.swift
//  iGarden
//

import SwiftUI

/// Kort velkomstskjerm som vises én gang ved første oppstart.
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)

            Text("Velkommen til iGarden")
                .font(.title.bold())

            VStack(alignment: .leading, spacing: 20) {
                featureRow(
                    icon: "plus.circle.fill",
                    title: "Registrer plantene dine",
                    text: "Navn, plassering, bilde og hvor ofte de skal vannes."
                )
                featureRow(
                    icon: "drop.fill",
                    title: "Hold vanningen i rute",
                    text: "Appen holder styr på hvem som trenger vann, og varsler deg når det er på tide."
                )
                featureRow(
                    icon: "photo.on.rectangle",
                    title: "Følg veksten",
                    text: "Ta bilder underveis og se utviklingen på tidslinjen."
                )
            }
            .padding(.horizontal, 8)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Kom i gang")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
        .interactiveDismissDisabled()
    }

    private func featureRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
