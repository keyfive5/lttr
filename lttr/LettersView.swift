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
                letter.companyName.localizedCaseInsensitiveContains(searchText) ||
                letter.notes.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.dateSent > $1.dateSent }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.letters.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "envelope.badge")
                            .font(.system(size: 64))
                            .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                        
                        VStack(spacing: 12) {
                            Text("No Letters Yet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                            
                            Text("Start tracking your letter writing hustle by adding your first letter")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingAddLetter = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Add First Letter")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(32)
                } else {
                    List {
                        ForEach(filteredLetters) { letter in
                            LetterRow(letter: letter, dataManager: dataManager)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteLetters)
                    }
                    .listStyle(PlainListStyle())
                    .searchable(text: $searchText, prompt: "Search letters...")
                    .background(Color(red: 0.98, green: 0.98, blue: 0.98))
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .navigationTitle("Letters Sent")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddLetter = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(letter.companyName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    
                    Text(letter.dateSent.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("$\(String(format: "%.0f", letter.expectedResponse))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                    
                    if letter.quantity > 1 {
                        Text("\(letter.quantity) letters")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.1))
                            .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                            .cornerRadius(12)
                    } else {
                        Text("Handwritten")
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.1))
                            .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                            .cornerRadius(12)
                    }
                }
            }
            
            if !letter.notes.isEmpty {
                Text(letter.notes)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .lineLimit(2)
            }
            
            HStack {
                if letter.isConfirmed {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                        Text("Confirmed")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.4))
                        Text("Pending")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.4))
                    }
                }
                
                Spacer()
                
                Button("Mark Received") {
                    markAsReceived()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.1))
                .cornerRadius(16)
                .disabled(letter.isConfirmed)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
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
    
    @State private var companyName = ""
    @State private var expectedResponse = ""
    @State private var quantity = 1
    @State private var notes = ""
    @State private var dateSent = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Company")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        TextField("Enter company name", text: $companyName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Currency")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        HStack {
                            Text("USD")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                            Spacer()
                            TextField("Amount", text: $expectedResponse)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Date Written")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        DatePicker("", selection: $dateSent, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quantity")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        HStack {
                            Text("\(quantity) letter\(quantity == 1 ? "" : "s")")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                            Spacer()
                            Stepper("", value: $quantity, in: 1...100)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tracking Number (Optional)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        TextField("Enter tracking number", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Assign to Drop")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        HStack {
                            Text("Select drop")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                        }
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        TextField("Optional notes...", text: $notes, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .navigationTitle("Add Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLetter()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.3, green: 0.8, blue: 0.5), Color(red: 0.2, green: 0.7, blue: 0.4)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(companyName.isEmpty || expectedResponse.isEmpty)
                }
            }
        }
    }
    
    func saveLetter() {
        guard let expectedResponseValue = Double(expectedResponse) else { return }
        
        let newLetter = Letter(
            dateSent: dateSent,
            companyName: companyName,
            expectedResponse: expectedResponseValue,
            notes: notes,
            quantity: quantity
        )
        
        dataManager.letters.append(newLetter)
        dataManager.saveData()
        dismiss()
    }
}

#Preview {
    LettersView(dataManager: DataManager())
} 