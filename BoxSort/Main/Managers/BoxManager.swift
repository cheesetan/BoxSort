//
//  BoxManager.swift
//  BoxSort
//
//  Created by Tristan Chay on 8/2/24.
//

import SwiftUI

struct Item: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var imageB64: String
}

struct Box: Codable, Identifiable {
    var id = UUID()
    var name: String
    var items: [Item]
}

class BoxManager: ObservableObject {
    static let shared: BoxManager = .init()
    
    @Published var boxes: [Box] = [] {
        didSet {
            save()
        }
    }
        
    init() {
        load()
    }
    
    func getArchiveURL() -> URL {
        let plistName = "boxes.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encodedBoxes = try? propertyListEncoder.encode(boxes)
        try? encodedBoxes?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
                
        if let retrievedBoxData = try? Data(contentsOf: archiveURL),
            let boxesDecoded = try? propertyListDecoder.decode([Box].self, from: retrievedBoxData) {
            boxes = boxesDecoded
        }
    }
}
