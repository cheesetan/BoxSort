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
    @State var urlToPassStringified: String = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: $showingBox) {
                    BoxRetrieverView(showingBox: $showingBox, urlToPassStringified: $urlToPassStringified)
                }
                .onOpenURL { url in
                    urlToPassStringified = url.description
                    showingBox = true
                }
        }
    }

}
