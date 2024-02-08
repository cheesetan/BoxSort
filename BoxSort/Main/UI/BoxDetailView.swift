//
//  BoxDetailView.swift
//  BoxSort
//
//  Created by Tristan Chay on 9/2/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct BoxDetailView: View {
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @Binding var box: Box
        
    var body: some View {
        List {
            Section {
                TextField("Box Name", text: $box.name)
            } header: {
                Text("Name")
            }
            
            Section {
                Image(uiImage: generateQRCode(from: box.id.uuidString))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .contextMenu {
                        Button {
                            UIImageWriteToSavedPhotosAlbum(generateQRCode(from: "boxsort://box?uuid=\(box.id.uuidString)").resized(toWidth: 1024)!, nil, nil, nil)
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                    }
            } header: {
                Text("QR Code")
            }
            
            Section {
                ForEach($box.items, id: \.id) { $item in
                    NavigationLink {
                        ItemDetailView(name: $item.name, description: $item.description, imageFileManagerUUID: $item.imageFileManagerUUID)
                    } label: {
                        VStack(alignment: .leading) {
                            Text($item.name.wrappedValue)
                                .font(.headline)
                            if !$item.description.wrappedValue.isEmpty {
                                Text($item.description.wrappedValue)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .onDelete { indexSet in
                    box.items.remove(atOffsets: indexSet)
                }
                .onMove { fromOffsets, toOffset in
                    box.items.move(fromOffsets: fromOffsets, toOffset: toOffset)
                }
                
                Button {
                    box.items.append(Item(name: "New Item", description: "", imageFileManagerUUID: ""))
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            } header: {
                Text("Items")
            }
        }
        .animation(.default, value: box.items.count)
        .navigationTitle(box.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
