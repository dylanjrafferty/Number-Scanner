//
//  VisionManager.swift
//  Number Scanner
//
//  Created by Dylan Rafferty on 2/19/22.
//

import UIKit
import Vision

@MainActor final class VisionManager: ObservableObject {
    
    @Published private(set) var localTaxRate = 0.06
    @Published private(set) var aggregate: Aggregate = .sumWithTax
    @Published private(set) var entries = [Double]()
    @Published private(set) var currentValue = 0.0
    @Published private(set) var isProcessing = false

    func process(from images: [UIImage]) async {
        isProcessing = true
        cleanUp()
        do {
            for image in images {
                guard let cgImage = image.cgImage else { throw VisionError.invalidImage }
                let strings = try await processImage(cgImage)
                var scannedNumbers = [Double]()
                strings.forEach { string in
                    if let double = Double(string) {
                        entries.append(double)
                        scannedNumbers.append(double)
                    }
                }
                performCalculation(with: scannedNumbers)
            }
            isProcessing = false
        } catch {
            print("There was an error: \(error.localizedDescription)")
            isProcessing = false
        }
    }
    
    private func cleanUp() {
        entries = []
        currentValue = 0.0
    }
    
    private func processImage(_ image: CGImage) async throws -> [String] {
        let requestHandler = VNImageRequestHandler(cgImage: image)
        let request = try await requestHandler.perform(requestHandler)
        guard let strings = request.recognizedStrings else { throw VisionError.unableToProcess }
        return strings
    }
    
    private func performCalculation(with doubles: [Double]) {
        switch aggregate {
        case .sum:
            currentValue = doubles.reduce(0, +)
        case .average:
            let sum = doubles.reduce(0, +)
            currentValue = sum / Double(doubles.count)
        case .sumWithTax:
            let sum = doubles.reduce(0, +)
            currentValue = sum * (1.00 + localTaxRate)
        }
    }
    
    func setTaxRate(_ localTaxRate: Double) {
        self.localTaxRate = localTaxRate
    }
    
    func setAggregate(_ aggregate: Aggregate) {
        self.aggregate = aggregate
    }
}

extension Collection where Element == String {
    
    var concatenated: String {
        reduce("", +)
    }
}

extension VNRequest {
    
    var recognizedStrings: [String]? {
        guard let observations = results as? [VNRecognizedTextObservation] else { return nil }
        let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
        return recognizedStrings
    }
}

extension VNImageRequestHandler {
    
    func perform(_ handler: VNImageRequestHandler) async throws -> VNRequest {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if error != nil { continuation.resume(throwing: VisionError.unableToProcess) }
            }
            continuation.resume(returning: request)
            do {
                try perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

}

enum VisionError: Error {
    case invalidImage
    case unableToProcess
}
