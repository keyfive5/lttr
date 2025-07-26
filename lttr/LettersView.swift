import SwiftUI

struct LettersView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddLetter = false
    @State private var searchText = ""
    
    var filteredLetters: [Letter] {
        if searchText.isEmpty {
            return dataManager.letters.sorted { $0.dateSent > $1.dateSent }
        } else {
            return dataManager.letters.filter { letter in
                letter.casinoName.localizedCaseInsensitiveContains(searchText) ||
                letter.notes.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dateSent > $1.dateSent }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.letters.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "envelope.badge")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("No Letters Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Start tracking your casino letters by adding your first one")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingAddLetter = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add First Letter")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredLetters) { letter in
                            LetterRow(letter: letter, dataManager: dataManager)
                        }
                        .onDelete(perform: deleteLetters)
                    }
                    .searchable(text: $searchText, prompt: "Search letters...")
                }
            }
            .navigationTitle("Letters Sent")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddLetter = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLetter) {
                AddLetterView(dataManager: dataManager)
            }
        }
    }
    
    func deleteLetters(offsets: IndexSet) {
        dataManager.letters.remove(atOffsets: offsets)
        dataManager.saveData()
    }
}

struct LetterRow: View {
    let letter: Letter
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(letter.casinoName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(letter.dateSent.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.0f", letter.expectedDrop))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text(letter.method.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            if !letter.notes.isEmpty {
                Text(letter.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                if letter.isConfirmed {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Confirmed")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text("Pending")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                Button("Mark Received") {
                    markAsReceived()
                }
                .font(.caption)
                .foregroundColor(.blue)
                .disabled(letter.isConfirmed)
            }
        }
        .padding(.vertical, 4)
    }
    
    func markAsReceived() {
        if let index = dataManager.letters.firstIndex(where: { $0.id == letter.id }) {
            dataManager.letters[index].isConfirmed = true
            dataManager.saveData()
        }
    }
}

struct AddLetterView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var casinoName = ""
    @State private var method: Letter.LetterMethod = .handwritten
    @State private var expectedDrop = ""
    @State private var notes = ""
    @State private var dateSent = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Letter Details") {
                    TextField("Casino Name", text: $casinoName)
                    
                    Picker("Method", selection: $method) {
                        ForEach(Letter.LetterMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    
                    TextField("Expected Drop Amount", text: $expectedDrop)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date Sent", selection: $dateSent, displayedComponents: .date)
                }
                
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLetter()
                    }
                    .disabled(casinoName.isEmpty || expectedDrop.isEmpty)
                }
            }
        }
    }
    
    func saveLetter() {
        guard let expectedDropValue = Double(expectedDrop) else { return }
        
        let newLetter = Letter(
            dateSent: dateSent,
            casinoName: casinoName,
            method: method,
            expectedDrop: expectedDropValue,
            notes: notes
        )
        
        dataManager.letters.append(newLetter)
        dataManager.saveData()
        dismiss()
    }
}

#Preview {
    LettersView(dataManager: DataManager())
} 