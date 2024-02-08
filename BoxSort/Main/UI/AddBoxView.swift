//
//  AddBoxView.swift
//  BoxSort
//
//  Created by Tristan Chay on 9/2/24.
//

import SwiftUI

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
                            ItemDetailView(name: $item.name, description: $item.description, imageB64: $item.imageB64)
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
