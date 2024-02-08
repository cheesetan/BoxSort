//
//  UIImage+base64.swift
//  BoxSort
//
//  Created by Tristan Chay on 9/2/24.
//

import SwiftUI

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}
