//
//  BoxSortApp.swift
//  BoxSort
//
//  Created by Tristan Chay on 8/2/24.
//

import SwiftUI

@main
struct BoxSortApp: App {
    
    @State var showingBox = false
    @State var boxToShow: Box? = nil
    
    @ObservedObject var boxManager: BoxManager = .shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showingBox) {
                    NavigationStack {
                        VStack {
                            if let nonNilBox = boxToShow {
                                List {
                                    Section {
                                        Text(nonNilBox.name)
                                    } header: {
                                        Text("Name")
                                    }
                                    
                                    Section {
                                        ForEach(nonNilBox.items, id: \.id) { item in
                                            NavigationLink {
                                                ItemDetailView(name: .constant(item.name), description: .constant(item.description), imageFileManagerUUID: .constant(item.imageFileManagerUUID))
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
                }
                .onOpenURL { url in
                    handleBoxQRCodeDeeplink(url: url)
                }
        }
    }
    
    func handleBoxQRCodeDeeplink(url: URL) {
        
        // accepts boxsort://box?uuid= links
        
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
            boxToShow = box
            showingBox = true
        }
    }
}
