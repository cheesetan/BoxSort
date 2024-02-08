//
//  BoxesView.swift
//  BoxSort
//
//  Created by Tristan Chay on 8/2/24.
//

import SwiftUI

struct BoxesView: View {
    
    @State var searchText = ""
    @State var showingAddBoxView = false
    
    @ObservedObject var boxManager: BoxManager = .shared
        
    var body: some View {
        NavigationStack {
            VStack {
                if boxManager.boxes.isEmpty {
                    ContentUnavailableView("No Boxes", systemImage: "shippingbox.fill", description: Text("You currently have no Boxes, click the + button in the upper right hand corner to add one!"))
                } else {
                    List {
                        ForEach(filteredBoxes, id: \.id) { $box in
                            NavigationLink {
                                BoxDetailView(box: $box)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text($box.name.wrappedValue)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    if searchText.isEmpty {
                                        Text("^[\($box.items.count) Items](inflect: true)")
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("^[\($box.items.filter({$0.name.wrappedValue.uppercased().contains(searchText.uppercased())}).count) Matches](inflect: true)")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        .onDelete { indexSet in
                            boxManager.boxes.remove(atOffsets: indexSet)
                        }
                        .onMove { fromOffsets, toOffset in
                            boxManager.boxes.move(fromOffsets: fromOffsets, toOffset: toOffset)
                        }
                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .overlay {
                        if !searchText.isEmpty && filteredBoxes.isEmpty {
                            ContentUnavailableView.search(text: searchText)
                        }
                    }
                }
            }
            .navigationTitle("Your Boxes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .disabled(boxManager.boxes.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddBoxView.toggle()
                    } label: {
                        Label("Add Box", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddBoxView) {
            AddBoxView()
        }
    }
    
    var filteredBoxes: Binding<[Box]> {
        if searchText.isEmpty {
            return $boxManager.boxes
        } else {
            var boxesToReturn: [Box] = []
            boxManager.boxes.forEach { box in
                box.items.forEach { item in
                    if item.name.uppercased().contains(searchText.uppercased()) {
                        boxesToReturn.append(box)
                    }
                }
            }
            
            let myArrayBinding = Binding(get: {
                boxesToReturn
            }, set: { newValue in
                boxesToReturn = newValue
            })
            
            return myArrayBinding
        }
    }
}

struct AddBoxView: View {
    
    @State var boxName: String = ""
    @State var items: [Item] = []
    
    @FocusState var focused: Bool
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var boxManager: BoxManager = .shared
    
    var allItemsHaveNames: Bool {
        var returnResult = true
        items.forEach { item in
            if item.name.isEmpty {
                returnResult = false
            }
        }
        return returnResult
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Box Name", text: $boxName)
                        .focused($focused)
                } header: {
                    Text("Name")
                }
                
                Section {
                    ForEach($items, id: \.id) { $item in
                        NavigationLink {
                            ItemInfoView(name: $item.name, description: $item.description, imageB64: $item.imageB64)
                        } label: {
                            VStack(alignment: .leading) {
                                Text($item.name.wrappedValue)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                if !$item.description.wrappedValue.isEmpty {
                                    Text($item.description.wrappedValue)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                    }
                    .onMove { fromOffsets, toOffset in
                        items.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    }
                    
                    Button {
                        withAnimation {
                            focused = false
                            items.append(Item(name: "New Item", description: "", imageB64: ""))
                        }
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                } header: {
                    Text("Items")
                }
                
                Section {
                    Button {
                        if !boxName.isEmpty && allItemsHaveNames {
                            withAnimation {
                                boxManager.boxes.insert(Box(name: boxName, items: items), at: 0)
                                dismiss.callAsFunction()
                            }
                        }
                    } label: {
                        Text("Add to Boxes")
                    }
                    .disabled(boxName.isEmpty || !allItemsHaveNames)
                }
            }
            .navigationTitle("Add Box")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss.callAsFunction()
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
        }
    }
}

struct ItemInfoView: View {
    
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

struct BoxDetailView: View {
    
    @Binding var box: Box
        
    var body: some View {
        List {
            Section {
                TextField("Box Name", text: $box.name)
            } header: {
                Text("Name")
            }
            
            Section {
                ForEach($box.items, id: \.id) { $item in
                    NavigationLink {
                        ItemInfoView(name: $item.name, description: $item.description, imageB64: $item.imageB64)
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
                    box.items.append(Item(name: "New Item", description: "", imageB64: ""))
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
}

struct CameraView: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            parent.dismiss.callAsFunction()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: PhotoPicker

        init(parent: PhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}

#Preview {
    BoxesView()
}
