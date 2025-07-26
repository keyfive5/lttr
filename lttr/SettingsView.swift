import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    
    var body: some View {
        NavigationView {
            List {
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
                        
                        Text("Casino Letter Tracker")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Track your casino letter profits and manage your side hustle efficiently.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
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
        }
    }
    
    func resetData() {
        // Show confirmation dialog
        // For now, just reset the data
        dataManager.letters.removeAll()
        dataManager.drops.removeAll()
        dataManager.casinos.removeAll()
        dataManager.loadDefaultCasinos()
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
            drops: dataManager.drops,
            casinos: dataManager.casinos,
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
            dataManager.drops = importedData.drops
            dataManager.casinos = importedData.casinos
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
    let drops: [Drop]
    let casinos: [Casino]
    let settings: UserSettings
    let exportDate: Date
}

#Preview {
    SettingsView(dataManager: DataManager())
} 