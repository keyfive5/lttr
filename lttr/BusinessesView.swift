import SwiftUI

struct SuppliesView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingAddSupply = false
    @State private var searchText = ""
    
    var filteredSupplies: [Supply] {
        if searchText.isEmpty {
            return dataManager.supplies.sorted { $0.datePurchased > $1.datePurchased }
        } else {
            return dataManager.supplies.filter { supply in
                supply.name.localizedCaseInsensitiveContains(searchText) ||
                supply.notes.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.datePurchased > $1.datePurchased }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if dataManager.supplies.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 60))
                            .foregroundColor(.purple)
                        
                        VStack(spacing: 8) {
                            Text("No Supplies Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Track your stamps, pens, envelopes, and other supplies")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button(action: { showingAddSupply = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add First Supply")
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
                        Section {
                            HStack {
                                Text("Total Spent")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("$\(String(format: "%.2f", dataManager.totalSupplyCost))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Section("Supplies") {
                            ForEach(filteredSupplies) { supply in
                                SupplyRow(supply: supply)
                            }
                            .onDelete(perform: deleteSupplies)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search supplies...")
                }
            }
            .navigationTitle("Supplies")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSupply = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSupply) {
                AddSupplyView(dataManager: dataManager)
            }
        }
    }
    
    func deleteSupplies(offsets: IndexSet) {
        dataManager.supplies.remove(atOffsets: offsets)
        dataManager.saveData()
    }
}

struct SupplyRow: View {
    let supply: Supply
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(supply.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(supply.datePurchased.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", supply.cost))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text("Qty: \(supply.quantity)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
            }
            
            if !supply.notes.isEmpty {
                Text(supply.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddSupplyView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var cost = ""
    @State private var notes = ""
    @State private var datePurchased = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Supply Details") {
                    TextField("Supply Name (e.g., Stamps, Envelopes)", text: $name)
                    
                    HStack {
                        Text("Quantity")
                        Spacer()
                        Stepper("\(quantity)", value: $quantity, in: 1...1000)
                    }
                    
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date Purchased", selection: $datePurchased, displayedComponents: .date)
                }
                
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Quick Add") {
                    VStack(spacing: 12) {
                        Text("Common Supplies")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            QuickAddButton(title: "Stamps", cost: 0.66, action: { addQuickSupply("Stamps", 0.66) })
                            QuickAddButton(title: "Envelopes", cost: 0.15, action: { addQuickSupply("Envelopes", 0.15) })
                            QuickAddButton(title: "Pens", cost: 2.99, action: { addQuickSupply("Pens", 2.99) })
                            QuickAddButton(title: "Paper", cost: 8.99, action: { addQuickSupply("Paper", 8.99) })
                        }
                    }
                }
            }
            .navigationTitle("Add Supply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSupply()
                    }
                    .disabled(name.isEmpty || cost.isEmpty)
                }
            }
        }
    }
    
    func saveSupply() {
        guard let costValue = Double(cost) else { return }
        
        let newSupply = Supply(
            name: name,
            quantity: quantity,
            cost: costValue,
            datePurchased: datePurchased,
            notes: notes
        )
        
        dataManager.supplies.append(newSupply)
        dataManager.saveData()
        dismiss()
    }
    
    func addQuickSupply(_ supplyName: String, _ supplyCost: Double) {
        name = supplyName
        cost = String(format: "%.2f", supplyCost)
    }
}

struct QuickAddButton: View {
    let title: String
    let cost: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("$\(String(format: "%.2f", cost))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SuppliesView(dataManager: DataManager())
}
