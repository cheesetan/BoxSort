//
//  BoxDetailView.swift
//  BoxSort
//
//  Created by Tristan Chay on 9/2/24.
//

import SwiftUI

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
                        ItemDetailView(name: $item.name, description: $item.description, imageB64: $item.imageB64)
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
