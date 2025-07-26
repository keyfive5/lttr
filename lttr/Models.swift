import Foundation
import SwiftUI

// MARK: - Data Models

struct Letter: Identifiable, Codable {
    let id = UUID()
    var dateSent: Date
    var casinoName: String
    var method: LetterMethod
    var expectedDrop: Double
    var notes: String
    var isConfirmed: Bool = false
    
    enum LetterMethod: String, CaseIterable, Codable {
        case handwritten = "Handwritten"
        case email = "Email"
        case typed = "Typed"
    }
}

struct Drop: Identifiable, Codable {
    let id = UUID()
    var dateReceived: Date
    var amount: Double
    var casinoName: String
    var linkedLetterId: UUID?
    var notes: String
}

struct Casino: Identifiable, Codable {
    let id = UUID()
    var name: String
    var address: String
    var responseRate: Double // percentage
    var preferredFormat: Letter.LetterMethod
    var expectedDropRange: ClosedRange<Double>
    var lastUpdated: Date
    var notes: String
}

struct UserSettings: Codable {
    var currency: String = "USD"
    var followUpReminderDays: Int = 30
    var notificationsEnabled: Bool = true
}

// MARK: - Data Manager

class DataManager: ObservableObject {
    @Published var letters: [Letter] = []
    @Published var drops: [Drop] = []
    @Published var casinos: [Casino] = []
    @Published var settings = UserSettings()
    
    private let lettersKey = "savedLetters"
    private let dropsKey = "savedDrops"
    private let casinosKey = "savedCasinos"
    private let settingsKey = "userSettings"
    
    init() {
        loadData()
        if casinos.isEmpty {
            loadDefaultCasinos()
        }
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(letters) {
            UserDefaults.standard.set(encoded, forKey: lettersKey)
        }
        if let encoded = try? JSONEncoder().encode(drops) {
            UserDefaults.standard.set(encoded, forKey: dropsKey)
        }
        if let encoded = try? JSONEncoder().encode(casinos) {
            UserDefaults.standard.set(encoded, forKey: casinosKey)
        }
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: lettersKey),
           let decoded = try? JSONDecoder().decode([Letter].self, from: data) {
            letters = decoded
        }
        if let data = UserDefaults.standard.data(forKey: dropsKey),
           let decoded = try? JSONDecoder().decode([Drop].self, from: data) {
            drops = decoded
        }
        if let data = UserDefaults.standard.data(forKey: casinosKey),
           let decoded = try? JSONDecoder().decode([Casino].self, from: data) {
            casinos = decoded
        }
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(UserSettings.self, from: data) {
            settings = decoded
        }
    }
    
    func loadDefaultCasinos() {
        casinos = [
            Casino(name: "Bellagio", address: "3600 S Las Vegas Blvd, Las Vegas, NV 89109", responseRate: 0.15, preferredFormat: .handwritten, expectedDropRange: 50...200, lastUpdated: Date(), notes: "High-end property, prefers handwritten letters"),
            Casino(name: "Caesars Palace", address: "3570 S Las Vegas Blvd, Las Vegas, NV 89109", responseRate: 0.12, preferredFormat: .typed, expectedDropRange: 25...150, lastUpdated: Date(), notes: "Classic Vegas casino"),
            Casino(name: "MGM Grand", address: "3799 S Las Vegas Blvd, Las Vegas, NV 89109", responseRate: 0.18, preferredFormat: .handwritten, expectedDropRange: 30...180, lastUpdated: Date(), notes: "Good response rate for handwritten"),
            Casino(name: "The Venetian", address: "3355 S Las Vegas Blvd, Las Vegas, NV 89109", responseRate: 0.10, preferredFormat: .email, expectedDropRange: 20...100, lastUpdated: Date(), notes: "Luxury property, accepts email")
        ]
        saveData()
    }
    
    // MARK: - Computed Properties
    
    var totalLettersSent: Int {
        letters.count
    }
    
    var totalDropsReceived: Int {
        drops.count
    }
    
    var totalAmountReceived: Double {
        drops.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpectedDrops: Double {
        letters.reduce(0) { $0 + $1.expectedDrop }
    }
    
    var roi: Double {
        guard totalExpectedDrops > 0 else { return 0 }
        return (totalAmountReceived / totalExpectedDrops - 1) * 100
    }
    
    var averageDropValue: Double {
        guard !drops.isEmpty else { return 0 }
        return totalAmountReceived / Double(drops.count)
    }
    
    var confirmedLetters: [Letter] {
        letters.filter { $0.isConfirmed }
    }
    
    var pendingLetters: [Letter] {
        letters.filter { !$0.isConfirmed }
    }
} 