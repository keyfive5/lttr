import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Profile") {
                    Button(action: { showingProfile = true }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                            Text("User Profile")
                            Spacer()
                            Text(dataManager.userProfile.username.isEmpty ? "Not Set" : dataManager.userProfile.username)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if dataManager.userProfile.subscriptionType == .trial {
                        HStack {
                            Text("Trial Status")
                            Spacer()
                            Text("\(dataManager.daysLeftInTrial) days left")
                                .foregroundColor(.orange)
                        }
                    } else {
                        HStack {
                            Text("Subscription")
                            Spacer()
                            Text(dataManager.userProfile.subscriptionType.rawValue)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Section("App Preferences") {
                    HStack {
                        Text("Currency")
                        Spacer()
                        Text(dataManager.settings.currency)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Follow-up Reminder")
                        Spacer()
                        Text("\(dataManager.settings.followUpReminderDays) days")
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Notifications", isOn: $dataManager.settings.notificationsEnabled)
                        .onChange(of: dataManager.settings.notificationsEnabled) { _ in
                            dataManager.saveData()
                        }
                }
                
                Section("Data Management") {
                    Button(action: { showingExportSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Export Data")
                        }
                    }
                    
                    Button(action: { showingImportSheet = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.green)
                            Text("Import Data")
                        }
                    }
                    
                    Button(action: resetData) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Reset All Data")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("App Information") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("lttr.")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Letter Tracker")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Track your letter writing profits and manage your side hustle efficiently.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Legal") {
                    Text("18+ verification required")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Terms of Service • Privacy Policy")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("Not affiliated with any casinos or gambling establishments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingExportSheet) {
                ExportView(dataManager: dataManager)
            }
            .sheet(isPresented: $showingImportSheet) {
                ImportView(dataManager: dataManager)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(dataManager: dataManager)
            }
        }
    }
    
    func resetData() {
        // Show confirmation dialog
        // For now, just reset the data
        dataManager.letters.removeAll()
        dataManager.responses.removeAll()
        dataManager.companies.removeAll()
        dataManager.supplies.removeAll()
        dataManager.calendarNotes.removeAll()
        dataManager.loadDefaultCompanies()
        dataManager.saveData()
    }
}

struct ProfileView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var newPostalCode = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section("Postal Codes") {
                    ForEach(dataManager.userProfile.postalCodes, id: \.self) { postalCode in
                        HStack {
                            Text(postalCode)
                            Spacer()
                            Button("Remove") {
                                if let index = dataManager.userProfile.postalCodes.firstIndex(of: postalCode) {
                                    dataManager.userProfile.postalCodes.remove(at: index)
                                    dataManager.saveData()
                                }
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .onDelete(perform: deletePostalCodes)
                    
                    HStack {
                        TextField("Add Postal Code", text: $newPostalCode)
                            .keyboardType(.numberPad)
                        
                        Button("Add") {
                            if !newPostalCode.isEmpty {
                                dataManager.userProfile.postalCodes.append(newPostalCode)
                                newPostalCode = ""
                                dataManager.saveData()
                            }
                        }
                        .disabled(newPostalCode.isEmpty)
                    }
                }
                
                Section("Subscription") {
                    HStack {
                        Text("Current Plan")
                        Spacer()
                        Text(dataManager.userProfile.subscriptionType.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    if dataManager.userProfile.subscriptionType == .trial {
                        HStack {
                            Text("Trial Ends")
                            Spacer()
                            Text("\(dataManager.daysLeftInTrial) days left")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                }
            }
            .onAppear {
                username = dataManager.userProfile.username
                email = dataManager.userProfile.email
            }
        }
    }
    
    func saveProfile() {
        dataManager.userProfile.username = username
        dataManager.userProfile.email = email
        dataManager.saveData()
        dismiss()
    }
    
    func deletePostalCodes(offsets: IndexSet) {
        dataManager.userProfile.postalCodes.remove(atOffsets: offsets)
        dataManager.saveData()
    }
}

struct ExportView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var exportData: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let export = ExportData(
            letters: dataManager.letters,
            responses: dataManager.responses,
            companies: dataManager.companies,
            supplies: dataManager.supplies,
            calendarNotes: dataManager.calendarNotes,
            userProfile: dataManager.userProfile,
            settings: dataManager.settings,
            exportDate: Date()
        )
        
        if let data = try? encoder.encode(export),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Export Data")
                    .font(.headline)
                    .padding()
                
                Text("Copy the data below to backup your information:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                ScrollView {
                    Text(exportData)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(8)
                        .padding()
                }
                
                Button("Copy to Clipboard") {
                    UIPasteboard.general.string = exportData
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ImportView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var importText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Import Data")
                    .font(.headline)
                    .padding()
                
                Text("Paste your exported data below:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                TextEditor(text: $importText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(8)
                    .padding()
                
                Button("Import Data") {
                    importData()
                }
                .buttonStyle(.borderedProminent)
                .disabled(importText.isEmpty)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Import") {
                        importData()
                    }
                    .disabled(importText.isEmpty)
                }
            }
            .alert("Import Result", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func importData() {
        guard let data = importText.data(using: .utf8) else {
            alertMessage = "Invalid data format"
            showingAlert = true
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let importedData = try decoder.decode(ExportData.self, from: data)
            
            dataManager.letters = importedData.letters
            dataManager.responses = importedData.responses
            dataManager.companies = importedData.companies
            dataManager.supplies = importedData.supplies
            dataManager.calendarNotes = importedData.calendarNotes
            dataManager.userProfile = importedData.userProfile
            dataManager.settings = importedData.settings
            dataManager.saveData()
            
            alertMessage = "Data imported successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to import data: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct ExportData: Codable {
    let letters: [Letter]
    let responses: [Response]
    let companies: [Company]
    let supplies: [Supply]
    let calendarNotes: [CalendarNote]
    let userProfile: UserProfile
    let settings: UserSettings
    let exportDate: Date
}

#Preview {
    SettingsView(dataManager: DataManager())
} 