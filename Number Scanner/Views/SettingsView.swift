//
//  SettingsView.swift
//  Number Scanner
//
//  Created by Dylan Rafferty on 2/20/22.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var visionManager: VisionManager
    @State private var computation: Aggregate = .sumWithTax
    @State private var localTaxRate = ""
    @State private var shouldShowAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField(text: $localTaxRate, prompt: Text("Tax Rate")) {
                        Text("Tax Rate")
                }
                Picker("Computation Type", selection: $computation) {
                    Text("Sum")
                        .tag(Aggregate.sum)
                    Text("Sum with tax")
                        .tag(Aggregate.sumWithTax)
                    Text("Average")
                        .tag(Aggregate.average)
                }
            }
        }
        .onChange(of: computation) { newValue in
            visionManager.setAggregate(newValue)
        }
        .onChange(of: localTaxRate) { newValue in
            guard let double = Double(newValue) else { shouldShowAlert = true; return }
            visionManager.setTaxRate(double)
        }
        .alert(isPresented: $shouldShowAlert) {
            Alert(title: Text("Error"), message: Text("Please enter a valid input for tax rate."), dismissButton: .default(Text("Okay")))
        }
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(VisionManager())
    }
}
