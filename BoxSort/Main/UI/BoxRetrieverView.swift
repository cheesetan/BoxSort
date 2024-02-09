//
//  BoxRetrieverView.swift
//  BoxSort
//
//  Created by Tristan Chay on 9/2/24.
//

import SwiftUI

struct BoxRetrieverView: View {
    
    @State var boxRetrieved: Box? = nil
    
    @Binding var showingBox: Bool
    @Binding var urlToPassStringified: String
    
    @ObservedObject var boxManager: BoxManager = .shared
    
    var body: some View {
        NavigationStack {
            VStack {
                if let box = boxRetrieved {
                    List {
                        Section {
                            Text(box.name)
                        } header: {
                            Text("Name")
                        }
                        
                        Section {
                            ForEach(box.items, id: \.id) { item in
                                NavigationLink {
                                    ItemDetailView(name: .constant(item.name), description: .constant(item.description), imageFileManagerUUID: .constant(item.imageFileManagerUUID), canEdit: false)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                        if !item.description.isEmpty {
                                            Text(item.description)
                                                .font(.callout)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        } header: {
                            Text("Items")
                        }
                    }
                    .navigationTitle(box.name)
                    .navigationBarTitleDisplayMode(.inline)
                } else {
                    ContentUnavailableView("Missing Box", systemImage: "questionmark.folder.fill", description: Text("The Box you requested does not exist or has been deleted."))
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingBox = false
                    } label: {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
        }
        .onAppear {
            handleBoxStringifiedUrl(stringifiedUrl: urlToPassStringified)
        }
    }
    
    func handleBoxStringifiedUrl(stringifiedUrl url: String) {
        
        // accepts boxsort://box?uuid= links
        
        guard let url = URL(string: url) else { return }
        
        print("Asked to open URL: \(url.description)")
        
        guard let scheme = url.scheme,
              scheme.localizedCaseInsensitiveCompare("boxsort") == .orderedSame
        else { return }
        
        var parameters: [String: String] = [:]
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        
        guard url.host == "box", let uuid = parameters["uuid"] else { return }
        boxManager.findBoxWithUUID(uuid: uuid) { box in
            print(box)
            boxRetrieved = box
        }
    }
}
