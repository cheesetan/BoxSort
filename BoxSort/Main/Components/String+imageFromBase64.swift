//
//  String+imageFromBase64.swift
//  BoxSort
//
//  Created by Tristan Chay on 9/2/24.
//

import SwiftUI

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
