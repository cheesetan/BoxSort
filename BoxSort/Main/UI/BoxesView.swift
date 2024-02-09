//
//  BoxesView.swift
//  BoxSort
//
//  Created by Tristan Chay on 8/2/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

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
                        if searchText.isEmpty {
                            ForEach(filteredBoxes, id: \.id) { $box in
                                NavigationLink {
                                    BoxDetailView(box: $box)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text($box.name.wrappedValue)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text("^[\($box.items.count) Items](inflect: true)")
                                            .foregroundStyle(.secondary)
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
                        } else {
                            ForEach(filteredBoxes, id: \.id) { $box in
                                ForEach($box.items, id: \.id) { $item in
                                    if $item.name.wrappedValue.uppercased().contains(searchText.uppercased()) {
                                        NavigationLink {
                                            BoxDetailView(box: $box)
                                        } label: {
                                            VStack(alignment: .leading) {
                                                Text($item.name.wrappedValue)
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                Text($box.name.wrappedValue)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(.vertical, 5)
                                        }
                                    }
                                }
                            }
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

#Preview {
    BoxesView()
}
