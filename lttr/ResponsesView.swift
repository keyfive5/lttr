import SwiftUI

struct ResponsesView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddResponse = false
    @State private var searchText = ""
    
    var filteredResponses: [Response] {
        if searchText.isEmpty {
            return dataManager.responses.sorted { $0.dateReceived > $1.dateReceived }
        } else {
            return dataManager.responses.filter { response in
                response.companyName.localizedCaseInsensitiveContains(searchText) ||
                response.notes.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dateReceived > $1.dateReceived }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.responses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        VStack(spacing: 8) {
                            Text("No Responses Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Track your responses as they come in")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingAddResponse = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add First Response")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredResponses) { response in
                            ResponseRow(response: response, dataManager: dataManager)
                        }
                        .onDelete(perform: deleteResponses)
                    }
                    .searchable(text: $searchText, prompt: "Search responses...")
                }
            }
            .navigationTitle("Responses Received")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddResponse = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddResponse) {
                AddResponseView(dataManager: dataManager)
            }
        }
    }
    
    func deleteResponses(offsets: IndexSet) {
        dataManager.responses.remove(atOffsets: offsets)
        dataManager.saveData()
    }
}

struct ResponseRow: View {
    let response: Response
    @ObservedObject var dataManager: DataManager
    
    var linkedLetter: Letter? {
        guard let linkedLetterId = response.linkedLetterId else { return nil }
        return dataManager.letters.first { $0.id == linkedLetterId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(response.companyName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(response.dateReceived.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.0f", response.amount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    if linkedLetter != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.caption)
                            Text("Linked")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            if let letter = linkedLetter {
                HStack {
                    Image(systemName: "envelope")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Linked to letter sent on \(letter.dateSent.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                }
            }
            
            if !response.notes.isEmpty {
                Text(response.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddResponseView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var companyName = ""
    @State private var amount = ""
    @State private var notes = ""
    @State private var dateReceived = Date()
    @State private var selectedLetterId: UUID?
    @State private var showingLetterPicker = false
    
    var availableLetters: [Letter] {
        dataManager.letters.filter { !$0.isConfirmed }
    }
    
    var selectedLetter: Letter? {
        guard let selectedLetterId = selectedLetterId else { return nil }
        return dataManager.letters.first { $0.id == selectedLetterId }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Response Details") {
                    TextField("Company Name", text: $companyName)
                    
                    TextField("Amount Received", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date Received", selection: $dateReceived, displayedComponents: .date)
                }
                
                Section("Link to Letter (Optional)") {
                    if availableLetters.isEmpty {
                        Text("No pending letters to link")
                            .foregroundColor(.secondary)
                    } else {
                        Button(action: { showingLetterPicker = true }) {
                            HStack {
                                Text("Select Letter")
                                Spacer()
                                if let letter = selectedLetter {
                                    Text(letter.companyName)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("None")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        if let letter = selectedLetter {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Selected Letter:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(letter.companyName) - $\(String(format: "%.0f", letter.expectedResponse))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Sent: \(letter.dateSent.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Response")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveResponse()
                    }
                    .disabled(companyName.isEmpty || amount.isEmpty)
                }
            }
            .sheet(isPresented: $showingLetterPicker) {
                LetterPickerView(
                    letters: availableLetters,
                    selectedLetterId: $selectedLetterId
                )
            }
        }
    }
    
    func saveResponse() {
        guard let amountValue = Double(amount) else { return }
        
        let newResponse = Response(
            dateReceived: dateReceived,
            amount: amountValue,
            companyName: companyName,
            linkedLetterId: selectedLetterId,
            notes: notes
        )
        
        dataManager.responses.append(newResponse)
        
        // Mark the linked letter as confirmed if one was selected
        if let selectedLetterId = selectedLetterId,
           let index = dataManager.letters.firstIndex(where: { $0.id == selectedLetterId }) {
            dataManager.letters[index].isConfirmed = true
        }
        
        dataManager.saveData()
        dismiss()
    }
}

struct LetterPickerView: View {
    let letters: [Letter]
    @Binding var selectedLetterId: UUID?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(letters) { letter in
                    Button(action: {
                        selectedLetterId = letter.id
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(letter.companyName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Sent: \(letter.dateSent.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$\(String(format: "%.0f", letter.expectedResponse))")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                if letter.quantity > 1 {
                                    Text("\(letter.quantity) letters")
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                } else {
                                    Text("Handwritten")
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ResponsesView(dataManager: DataManager())
}
