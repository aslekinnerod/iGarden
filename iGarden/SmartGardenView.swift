//
//  SmartGardenView.swift
//  iGarden
//
//  «Smart hage»: jord-pH per bed og anbefalinger om hvilke planter
//  som bør flyttes til bed med bedre egnet jord.
//

import SwiftUI

struct SmartGardenView: View {
    @Environment(GardenStore.self) private var gardenStore
    @Environment(\.dismiss) private var dismiss

    private var beds: [CustomLocation] { gardenStore.customLocations }

    private var recommendations: [SoilRecommendation] {
        SoilAdvisor.recommendations(plants: gardenStore.plants, beds: beds)
    }

    /// Planter i bed med målt pH som trives der de står.
    private var thrivingCount: Int {
        let bedsByName = Dictionary(grouping: beds, by: \.name).compactMapValues(\.first)
        return gardenStore.plants.filter { plant in
            guard let bed = bedsByName[plant.location] else { return false }
            return SoilFit.evaluate(plant: plant, bedPH: bed.soilPH) == .good
        }.count
    }

    var body: some View {
        NavigationStack {
            List {
                if beds.isEmpty {
                    ContentUnavailableView {
                        Label("Ingen bed ennå", systemImage: "square.grid.2x2")
                    } description: {
                        Text("Legg til egne plasseringer (bed) i planteskjemaet, så kan du måle og registrere jord-pH her.")
                    }
                } else {
                    bedsSection
                    recommendationsSection
                }
            }
            .navigationTitle("Smart hage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
        }
    }

    private var bedsSection: some View {
        Section {
            ForEach(beds) { bed in
                bedRow(bed)
            }
        } header: {
            Text("Bed og jord")
        } footer: {
            Text("Mål pH med en jordtester og juster verdien her. Uten pH kan ikke bedet vurderes.")
        }
    }

    private func bedRow(_ bed: CustomLocation) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(bed.name)
                if let ph = bed.soilPH {
                    Text("pH \(ph.formatted(.number.precision(.fractionLength(1)))) · \(soilCharacter(ph))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("pH ikke målt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Stepper(
                "pH",
                value: Binding(
                    get: { bed.soilPH ?? 6.5 },
                    set: { gardenStore.setSoilPH($0, for: bed) }
                ),
                in: 3.5...9.0,
                step: 0.1
            )
            .labelsHidden()
        }
        .swipeActions(edge: .trailing) {
            if bed.soilPH != nil {
                Button("Fjern pH") {
                    gardenStore.setSoilPH(nil, for: bed)
                }
                .tint(.orange)
            }
        }
    }

    private func soilCharacter(_ ph: Double) -> String {
        switch ph {
        case ..<5.5: String(localized: "sur jord")
        case ..<6.5: String(localized: "svakt sur jord")
        case ..<7.5: String(localized: "nøytral jord")
        default: String(localized: "kalkrik jord")
        }
    }

    @ViewBuilder
    private var recommendationsSection: some View {
        Section {
            if recommendations.isEmpty {
                if thrivingCount > 0 {
                    Label {
                        Text("Alle vurderte planter står i jord de trives i.")
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                } else {
                    Text("Ingen planter å vurdere ennå. Sett pH på bedene og pH-preferanse på plantene, så dukker anbefalingene opp her.")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(recommendations) { recommendation in
                    recommendationRow(recommendation)
                }
            }
        } header: {
            Text("Anbefalinger")
        } footer: {
            if thrivingCount > 0 && !recommendations.isEmpty {
                Text("\(thrivingCount) planter trives der de står.")
            }
        }
    }

    private func recommendationRow(_ recommendation: SoilRecommendation) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(recommendation.plant.name)
                    .font(.headline)
            }
            Text(reasonText(recommendation))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let suggested = recommendation.suggestedBed, let ph = suggested.soilPH {
                Button {
                    movePlant(recommendation.plant, to: suggested)
                } label: {
                    Label(
                        String(localized: "Flytt til \(suggested.name) (pH \(ph.formatted(.number.precision(.fractionLength(1)))))"),
                        systemImage: "arrow.right.circle.fill"
                    )
                }
                .buttonStyle(.borderless)
            } else {
                Text("Ingen av bedene dine har passende pH – vurder å justere jorden eller lage et nytt bed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func reasonText(_ recommendation: SoilRecommendation) -> String {
        let bedName = recommendation.currentBed.name
        let bedPH = (recommendation.currentBed.soilPH ?? 0).formatted(.number.precision(.fractionLength(1)))
        let range = recommendation.plant.preferredPHText ?? ""
        switch recommendation.fit {
        case .tooAcidic:
            return String(localized: "\(bedName) (pH \(bedPH)) er for surt – planten vil ha pH \(range).")
        case .tooAlkaline:
            return String(localized: "\(bedName) (pH \(bedPH)) er for kalkrikt – planten vil ha pH \(range).")
        case .good, .unknown:
            return ""
        }
    }

    private func movePlant(_ plant: Plant, to bed: CustomLocation) {
        var moved = plant
        moved.location = bed.name
        gardenStore.updatePlant(moved)
    }
}

#Preview {
    SmartGardenView()
        .environment(GardenStore())
}
