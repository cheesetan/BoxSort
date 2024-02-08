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
    @Binding var imageB64: String
    
    var body: some View {
        List {
            Section {
                TextField("Item Name", text: $name)
                TextField("Item Description (Optional)", text: $description)
            } header: {
                Text("Information")
            }
            
            Section {
                if !imageB64.isEmpty, let image = imageB64.imageFromBase64 {
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
                    
                    if !imageB64.isEmpty {
                        Divider()
                        Button(role: .destructive) {
                            imageB64 = ""
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                } label: {
                    Text(imageB64.isEmpty ? "Add Photo" : "Change Photo")
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
            if let image = selectedImage {
                imageB64 = image.base64 ?? ""
            }
        }
    }
}
