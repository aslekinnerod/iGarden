//
//  ImageStore.swift
//  iGarden
//
//  Laster plantebilder fra Firebase Storage med minne- og diskcache,
//  så liste, tidslinje og slideshow ikke laster samme bilde flere ganger.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseStorage

actor ImageStore {
    static let shared = ImageStore()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskDirectory: URL
    private var inFlight: [String: Task<UIImage?, Never>] = [:]

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskDirectory = caches.appendingPathComponent("PlantPhotos", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskDirectory, withIntermediateDirectories: true)
    }

    func image(forPath path: String) async -> UIImage? {
        let key = path as NSString
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }
        if let existing = inFlight[path] {
            return await existing.value
        }
        let task = Task<UIImage?, Never> {
            if let data = try? Data(contentsOf: diskURL(for: path)), let image = UIImage(data: data) {
                return image
            }
            guard let data = try? await Storage.storage().reference(withPath: path)
                .data(maxSize: 10 * 1024 * 1024) else { return nil }
            try? data.write(to: diskURL(for: path))
            return UIImage(data: data)
        }
        inFlight[path] = task
        let image = await task.value
        inFlight[path] = nil
        if let image {
            memoryCache.setObject(image, forKey: key)
        }
        return image
    }

    /// Legger et nytt bilde rett i cachen ved opplasting, så det vises umiddelbart.
    func store(_ image: UIImage, forPath path: String) {
        memoryCache.setObject(image, forKey: path as NSString)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: diskURL(for: path))
        }
    }

    private func diskURL(for path: String) -> URL {
        diskDirectory.appendingPathComponent(path.replacingOccurrences(of: "/", with: "_"))
    }
}

/// Viser et plantebilde fra Storage-sti, med plassholder mens det lastes.
struct PlantPhotoView<Placeholder: View>: View {
    let path: String?
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder()
            }
        }
        .task(id: path) {
            image = nil
            guard let path else { return }
            image = await ImageStore.shared.image(forPath: path)
        }
    }
}
