//
//  Images.swift
//  DesignSystem
//
//  Created by Timur  on 09.10.2026.
//

import UIKit

public enum Images {
    public static let autodoc: UIImage = getImage("autodoc")

    private static func getImage(_ name: String) -> UIImage {
        guard let image = UIImage(named: name, in: bundle, with: nil) else {
            return UIImage()
        }

        return image
    }

    private static let bundle = Bundle(for: BundleHolder.self)
}

private final class BundleHolder {

}
