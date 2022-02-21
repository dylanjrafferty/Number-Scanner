//
//  Number_ScannerApp.swift
//  Number Scanner
//
//  Created by Dylan Rafferty on 2/19/22.
//

import SwiftUI

@main
struct Number_ScannerApp: App {
    @StateObject private var visionManager = VisionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(visionManager)
        }
    }
}
