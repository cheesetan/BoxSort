//
//  ItemDetailView.swift
//  BoxSort
//
//  Created by Tristan Chay on 9/2/24.
//

import SwiftUI

struct ItemDetailView: View {
    
    @State var showingCameraView = false
    @State var showingPhotoPicker = false
    
    @State var selectedImage: UIImage? = nil
    
    @Binding var name: String
    @Binding var description: String
    @Binding var imageFileManagerUUID: String
    
    var body: some View {
        List {
            Section {
                TextField("Item Name", text: $name)
                TextField("Item Description (Optional)", text: $description)
            } header: {
                Text("Information")
            }
            
            Section {
                if !imageFileManagerUUID.isEmpty, let image = UIImage(contentsOfFile: FileManager.documentsDirectory.appendingPathComponent("\(imageFileManagerUUID).jpg").path()) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 400)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Menu {
                    Button {
                        showingPhotoPicker.toggle()
                    } label: {
                        Label("Photo Library", systemImage: "photo.on.rectangle")
                    }
                    
                    Button {
                        showingCameraView.toggle()
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    if !imageFileManagerUUID.isEmpty {
                        Divider()
                        Button(role: .destructive) {
                            imageFileManagerUUID = ""
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                } label: {
                    Text(imageFileManagerUUID.isEmpty ? "Add Photo" : "Change Photo")
                }
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCameraView) {
            CameraView(image: $selectedImage)
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) {
            if let selectedImage = selectedImage {
                let uuid = UUID()
                imageFileManagerUUID = uuid.uuidString
                writeToDisk(image: selectedImage, imageName: uuid.uuidString)
            }
        }
    }
    
    func writeToDisk(image: UIImage, imageName: String) {
        let savePath = FileManager.documentsDirectory.appendingPathComponent("\(imageName).jpg") //Where are I want to store my data
        if let jpegData = image.jpegData(compressionQuality: 0.5) { // I can adjust the compression quality.
            try? jpegData.write(to: savePath, options: [.atomic, .completeFileProtection])
        }
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
