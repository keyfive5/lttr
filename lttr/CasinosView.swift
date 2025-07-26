import SwiftUI

struct CasinosView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddCasino = false
    @State private var searchText = ""
    
    var filteredCasinos: [Casino] {
        if searchText.isEmpty {
            return dataManager.casinos.sorted { $0.name < $1.name }
        } else {
            return dataManager.casinos.filter { casino in
                casino.name.localizedCaseInsensitiveContains(searchText) ||
                casino.address.localizedCaseInsensitiveContains(searchText) ||
                casino.notes.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.casinos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "building.2")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 8) {
                            Text("No Casinos Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Add casinos to track their rules and response rates")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingAddCasino = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add First Casino")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(filteredCasinos) { casino in
                            CasinoRow(casino: casino, dataManager: dataManager)
                        }
                        .onDelete(perform: deleteCasinos)
                    }
                    .searchable(text: $searchText, prompt: "Search casinos...")
                }
            }
            .navigationTitle("Casinos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddCasino = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCasino) {
                AddCasinoView(dataManager: dataManager)
            }
        }
    }
    
    func deleteCasinos(offsets: IndexSet) {
        dataManager.casinos.remove(atOffsets: offsets)
        dataManager.saveData()
    }
}

struct CasinoRow: View {
    let casino: Casino
    @ObservedObject var dataManager: DataManager
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(casino.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(casino.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(casino.responseRate * 100))%")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        Text("Response Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Text(casino.preferredFormat.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    
                    Text("$\(String(format: "%.0f", casino.expectedDropRange.lowerBound))-$\(String(format: "%.0f", casino.expectedDropRange.upperBound))")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                    
                    Spacer()
                }
                
                if !casino.notes.isEmpty {
                    Text(casino.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            CasinoDetailView(casino: casino, dataManager: dataManager)
        }
    }
}

struct CasinoDetailView: View {
    let casino: Casino
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(casino.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(casino.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        StatCard(
                            title: "Response Rate",
                            value: "\(Int(casino.responseRate * 100))%",
                            icon: "percent",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Preferred Format",
                            value: casino.preferredFormat.rawValue,
                            icon: "doc.text",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Expected Range",
                            value: "$\(String(format: "%.0f", casino.expectedDropRange.lowerBound))-$\(String(format: "%.0f", casino.expectedDropRange.upperBound))",
                            icon: "dollarsign.circle",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Last Updated",
                            value: casino.lastUpdated.formatted(date: .abbreviated, time: .omitted),
                            icon: "calendar",
                            color: .purple
                        )
                    }
                    
                    // Notes
                    if !casino.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(casino.notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        let casinoLetters = dataManager.letters.filter { $0.casinoName == casino.name }
                        let casinoDrops = dataManager.drops.filter { $0.casinoName == casino.name }
                        
                        if casinoLetters.isEmpty && casinoDrops.isEmpty {
                            Text("No activity with this casino yet")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(casinoLetters.prefix(3)) { letter in
                                    HStack {
                                        Image(systemName: "envelope")
                                            .foregroundColor(.blue)
                                        Text("Letter sent on \(letter.dateSent.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.subheadline)
                                        Spacer()
                                        Text("$\(String(format: "%.0f", letter.expectedDrop))")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                ForEach(casinoDrops.prefix(3)) { drop in
                                    HStack {
                                        Image(systemName: "dollarsign.circle")
                                            .foregroundColor(.green)
                                        Text("Drop received on \(drop.dateReceived.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.subheadline)
                                        Spacer()
                                        Text("$\(String(format: "%.0f", drop.amount))")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Casino Details")
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
}

struct AddCasinoView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var address = ""
    @State private var responseRate = ""
    @State private var preferredFormat: Letter.LetterMethod = .handwritten
    @State private var expectedDropMin = ""
    @State private var expectedDropMax = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Casino Details") {
                    TextField("Casino Name", text: $name)
                    TextField("Address", text: $address)
                    
                    HStack {
                        Text("Response Rate")
                        Spacer()
                        TextField("0-100", text: $responseRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                    }
                    
                    Picker("Preferred Format", selection: $preferredFormat) {
                        ForEach(Letter.LetterMethod.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                }
                
                Section("Expected Drop Range") {
                    HStack {
                        Text("Min")
                        Spacer()
                        TextField("Amount", text: $expectedDropMin)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Max")
                        Spacer()
                        TextField("Amount", text: $expectedDropMax)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Casino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCasino()
                    }
                    .disabled(name.isEmpty || address.isEmpty || responseRate.isEmpty || expectedDropMin.isEmpty || expectedDropMax.isEmpty)
                }
            }
        }
    }
    
    func saveCasino() {
        guard let responseRateValue = Double(responseRate),
              let minDrop = Double(expectedDropMin),
              let maxDrop = Double(expectedDropMax) else { return }
        
        let newCasino = Casino(
            name: name,
            address: address,
            responseRate: responseRateValue / 100,
            preferredFormat: preferredFormat,
            expectedDropRange: minDrop...maxDrop,
            lastUpdated: Date(),
            notes: notes
        )
        
        dataManager.casinos.append(newCasino)
        dataManager.saveData()
        dismiss()
    }
}

#Preview {
    CasinosView(dataManager: DataManager())
} 