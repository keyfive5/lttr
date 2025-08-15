import Foundation
import SwiftUI

// MARK: - Data Models

struct Letter: Identifiable, Codable {
    let id = UUID()
    var dateSent: Date
    var companyName: String
    var expectedResponse: Double
    var notes: String
    var isConfirmed: Bool = false
    var quantity: Int = 1 // For multiple letters
}

struct Response: Identifiable, Codable {
    let id = UUID()
    var dateReceived: Date
    var amount: Double
    var companyName: String
    var linkedLetterId: UUID?
    var notes: String
}

struct Company: Identifiable, Codable {
    let id = UUID()
    var name: String
    var address: String
    var responseRate: Double // percentage
    var expectedResponseRange: ClosedRange<Double>
    var lastUpdated: Date
    var notes: String
}

struct Supply: Identifiable, Codable {
    let id = UUID()
    var name: String
    var quantity: Int
    var cost: Double
    var datePurchased: Date
    var notes: String
}

struct CalendarNote: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var title: String
    var notes: String
    var type: NoteType
    
    enum NoteType: String, CaseIterable, Codable {
        case letter = "Letter"
        case response = "Response"
        case supply = "Supply"
        case general = "General"
    }
}

struct UserProfile: Codable {
    var username: String = ""
    var email: String = ""
    var postalCodes: [String] = []
    var subscriptionType: SubscriptionType = .trial
    var trialStartDate: Date = Date()
    
    enum SubscriptionType: String, CaseIterable, Codable {
        case trial = "Trial"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
}

struct UserSettings: Codable {
    var currency: String = "USD"
    var followUpReminderDays: Int = 30
    var notificationsEnabled: Bool = true
}

// MARK: - Data Manager

class DataManager: ObservableObject {
    @Published var letters: [Letter] = []
    @Published var responses: [Response] = []
    @Published var companies: [Company] = []
    @Published var supplies: [Supply] = []
    @Published var calendarNotes: [CalendarNote] = []
    @Published var userProfile = UserProfile()
    @Published var settings = UserSettings()
    
    private let lettersKey = "savedLetters"
    private let responsesKey = "savedResponses"
    private let companiesKey = "savedCompanies"
    private let suppliesKey = "savedSupplies"
    private let calendarNotesKey = "savedCalendarNotes"
    private let userProfileKey = "userProfile"
    private let settingsKey = "userSettings"
    
    init() {
        loadData()
        if companies.isEmpty {
            loadDefaultCompanies()
        }
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(letters) {
            UserDefaults.standard.set(encoded, forKey: lettersKey)
        }
        if let encoded = try? JSONEncoder().encode(responses) {
            UserDefaults.standard.set(encoded, forKey: responsesKey)
        }
        if let encoded = try? JSONEncoder().encode(companies) {
            UserDefaults.standard.set(encoded, forKey: companiesKey)
        }
        if let encoded = try? JSONEncoder().encode(supplies) {
            UserDefaults.standard.set(encoded, forKey: suppliesKey)
        }
        if let encoded = try? JSONEncoder().encode(calendarNotes) {
            UserDefaults.standard.set(encoded, forKey: calendarNotesKey)
        }
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userProfileKey)
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
        if let data = UserDefaults.standard.data(forKey: responsesKey),
           let decoded = try? JSONDecoder().decode([Response].self, from: data) {
            responses = decoded
        }
        if let data = UserDefaults.standard.data(forKey: companiesKey),
           let decoded = try? JSONDecoder().decode([Company].self, from: data) {
            companies = decoded
        }
        if let data = UserDefaults.standard.data(forKey: suppliesKey),
           let decoded = try? JSONDecoder().decode([Supply].self, from: data) {
            supplies = decoded
        }
        if let data = UserDefaults.standard.data(forKey: calendarNotesKey),
           let decoded = try? JSONDecoder().decode([CalendarNote].self, from: data) {
            calendarNotes = decoded
        }
        if let data = UserDefaults.standard.data(forKey: userProfileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
        if let data = UserDefaults.standard.data(forKey: settingsKey),
           let decoded = try? JSONDecoder().decode(UserSettings.self, from: data) {
            settings = decoded
        }
    }
    
    func loadDefaultCompanies() {
        companies = [
            Company(name: "Local Restaurant", address: "123 Main St, City, State", responseRate: 0.15, expectedResponseRange: 25...100, lastUpdated: Date(), notes: "Family-owned business"),
            Company(name: "Small Business Inc", address: "456 Oak Ave, City, State", responseRate: 0.12, expectedResponseRange: 20...75, lastUpdated: Date(), notes: "Professional business"),
            Company(name: "Community Center", address: "789 Pine Rd, City, State", responseRate: 0.18, expectedResponseRange: 15...60, lastUpdated: Date(), notes: "Good response rate"),
            Company(name: "Local Shop", address: "321 Elm St, City, State", responseRate: 0.10, expectedResponseRange: 10...50, lastUpdated: Date(), notes: "Modern business")
        ]
        saveData()
    }
    
    // MARK: - Computed Properties
    
    var totalLettersSent: Int {
        letters.reduce(0) { $0 + $1.quantity }
    }
    
    var totalResponsesReceived: Int {
        responses.count
    }
    
    var totalAmountReceived: Double {
        responses.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpectedResponses: Double {
        letters.reduce(0) { $0 + ($1.expectedResponse * Double($1.quantity)) }
    }
    
    var roi: Double {
        guard totalExpectedResponses > 0 else { return 0 }
        return (totalAmountReceived / totalExpectedResponses - 1) * 100
    }
    
    var averageResponseValue: Double {
        guard !responses.isEmpty else { return 0 }
        return totalAmountReceived / Double(responses.count)
    }
    
    var confirmedLetters: [Letter] {
        letters.filter { $0.isConfirmed }
    }
    
    var pendingLetters: [Letter] {
        letters.filter { !$0.isConfirmed }
    }
    
    var totalSupplyCost: Double {
        supplies.reduce(0) { $0 + $1.cost }
    }
    
    var isTrialExpired: Bool {
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: userProfile.trialStartDate) ?? Date()
        return Date() > trialEndDate && userProfile.subscriptionType == .trial
    }
    
    var daysLeftInTrial: Int {
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: userProfile.trialStartDate) ?? Date()
        let days = Calendar.current.dateComponents([.day], from: Date(), to: trialEndDate).day ?? 0
        return max(0, days)
    }
} 