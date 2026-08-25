//
//  SlideshowView.swift
//  iGarden
//

import SwiftUI

/// Fullskjerms avspilling av veksttidslinjen: hvert bilde vises i 2 sekunder
/// og fader over til neste. Avsluttes automatisk etter siste bilde, eller
/// ved trykk på skjermen/lukkeknappen.
struct SlideshowView: View {
    @Environment(\.dismiss) private var dismiss

    let photos: [PlantPhoto]

    @State private var index = 0

    private static let secondsPerPhoto: Double = 2
    private static let fadeDuration: Double = 0.6

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image = photos[index].image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .id(index)
                    .transition(.opacity)
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                Spacer()
                Text(photos[index].date.formatted(date: .long, time: .omitted))
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.bottom, 8)
            }
            .padding()
        }
        .animation(.easeInOut(duration: Self.fadeDuration), value: index)
        .contentShape(Rectangle())
        .onTapGesture { dismiss() }
        .statusBarHidden()
        .task { await play() }
    }

    private func play() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(Self.secondsPerPhoto))
            guard !Task.isCancelled else { return }
            if index < photos.count - 1 {
                index += 1
            } else {
                dismiss()
                return
            }
        }
    }
}
