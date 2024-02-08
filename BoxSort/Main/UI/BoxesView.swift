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
                                        Text("^[\($box.items.filter({$0.name.wrappedValue.uppercased().contains(searchText.uppercased())}).count) Items](inflect: true) matching search")
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
                var alreadyAdded = false
                box.items.forEach { item in
                    if item.name.uppercased().contains(searchText.uppercased()) {
                        boxesToReturn.append(box)
                        alreadyAdded = true
                    }
                }
                if !alreadyAdded {
                    if box.name.uppercased().contains(searchText.uppercased()) {
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
