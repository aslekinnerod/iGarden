//
//  OnboardingView.swift
//  iGarden
//

import SwiftUI

/// Kort velkomstskjerm som vises én gang ved første oppstart.
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            hero

            VStack(alignment: .leading, spacing: DS.Spacing.s5) {
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
            .padding(.horizontal, DS.Spacing.s6)
            .padding(.top, DS.Spacing.s6)

            Spacer(minLength: DS.Spacing.s6)

            Button {
                dismiss()
            } label: {
                Text("Kom i gang")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, DS.Spacing.s6)
            .padding(.bottom, DS.Spacing.s6)
        }
        .background(Color(.systemBackground))
        .interactiveDismissDisabled()
    }

    /// Hagebildet fyller toppen av arket, med tittelen lagt over en
    /// mørk toning nederst så teksten er lesbar uansett motiv.
    private var hero: some View {
        Image("OnboardingGarden")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 320)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.clear, .green900.opacity(0.45), .green900.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: DS.Spacing.s1) {
                        Label("iGarden", systemImage: "leaf.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                        Text("Velkommen til hagen din")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                    }
                    .padding(DS.Spacing.s6)
                }
            }
            .ignoresSafeArea(edges: .top)
            .accessibilityLabel("En frodig blomsterhage med rosebue, fontene og steinsti")
    }

    private func featureRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Spacing.s3 + 2) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: DS.Spacing.s8)
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
    Text("Bak arket")
        .sheet(isPresented: .constant(true)) {
            OnboardingView()
        }
}
