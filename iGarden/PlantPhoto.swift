//
//  PlantPhoto.swift
//  iGarden
//

import Foundation
import SwiftData
import UIKit

@Model
final class PlantPhoto {
    var date: Date
    @Attribute(.externalStorage) var imageData: Data
    var plant: Plant?

    init(imageData: Data, date: Date = .now) {
        self.imageData = imageData
        self.date = date
    }

    var image: UIImage? {
        UIImage(data: imageData)
    }
}

extension UIImage {
    /// Nedskalerer til maks 1200 px lengste side og komprimerer til JPEG,
    /// så databasen ikke fylles av kamerabilder i full oppløsning.
    func downscaledJPEGData(maxDimension: CGFloat = 1200, quality: CGFloat = 0.8) -> Data? {
        let scale = min(1, maxDimension / max(size.width, size.height))
        guard scale < 1 else { return jpegData(compressionQuality: quality) }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let resized = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
