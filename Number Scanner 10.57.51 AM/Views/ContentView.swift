//
//  ContentView.swift
//  Number Scanner
//
//  Created by Dylan Rafferty on 2/19/22.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "slider.horizontal.below.square.filled.and.square")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VisionManager())
    }
}
