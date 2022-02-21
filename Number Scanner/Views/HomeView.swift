//
//  HomeView.swift
//  Number Scanner
//
//  Created by Dylan Rafferty on 2/19/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var visionManager: VisionManager
    @State private var scannerIsPresented = false
    @State private var shouldShowAlert = false
    
    var body: some View {
        ZStack {
            if visionManager.isProcessing {
                ProgressView()
            }
            VStack {
                List {
                    Text("Scanned Values")
                    ForEach(visionManager.entries, id: \.self) { entry in
                        Text("\(entry)")
                    }
                    Text("Total: \(visionManager.currentValue)")
                    Button("Scan") { scannerIsPresented = true }
                }
            }
            .disabled(visionManager.isProcessing)
            .blur(radius: visionManager.isProcessing ? 3 : 0)
        }
        .fullScreenCover(isPresented: $scannerIsPresented) {
            ScannerView { result in
                switch result {
                case .success(let images):
                    scannerIsPresented = false
                    Task {
                        await visionManager.process(from: images)
                    }
                case .failure(_):
                    shouldShowAlert = true
                }
            } didCancelScanning: {
                scannerIsPresented = false
            }
        }
        .alert(isPresented: $shouldShowAlert) {
            Alert(title: Text("Error"), message: Text("There was an error, please try again."), dismissButton: .default(Text("Okay")))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(VisionManager())
    }
}

enum Aggregate {
    case sum
    case average
    case sumWithTax
}
