import SwiftUI

struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    metricsGrid
                    recentActivitySection
                    Spacer(minLength: 100)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("lttr.")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Casino Letter Tracker")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Letters Sent",
                value: "\(dataManager.totalLettersSent)",
                icon: "envelope.fill",
                color: .blue
            )
            
            MetricCard(
                title: "Drops Received",
                value: "\(dataManager.totalDropsReceived)",
                icon: "dollarsign.circle.fill",
                color: .green
            )
            
            MetricCard(
                title: "Total Received",
                value: "$\(String(format: "%.0f", dataManager.totalAmountReceived))",
                icon: "banknote.fill",
                color: .orange
            )
            
            MetricCard(
                title: "ROI",
                value: "\(String(format: "%.1f", dataManager.roi))%",
                icon: "chart.line.uptrend.xyaxis",
                color: dataManager.roi >= 0 ? .green : .red
            )
        }
        .padding(.horizontal)
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if dataManager.letters.isEmpty && dataManager.drops.isEmpty {
                emptyStateView
            } else {
                activityListView
            }
        }
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No activity yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Start by sending your first letter!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var activityListView: some View {
        VStack(spacing: 8) {
            ForEach(dataManager.letters.prefix(3)) { letter in
                ActivityRow(
                    title: "Letter sent to \(letter.casinoName)",
                    subtitle: letter.dateSent.formatted(date: .abbreviated, time: .omitted),
                    icon: "envelope",
                    color: .blue
                )
            }
            
            ForEach(dataManager.drops.prefix(3)) { drop in
                ActivityRow(
                    title: "Drop received from \(drop.casinoName)",
                    subtitle: "$\(String(format: "%.0f", drop.amount)) • \(drop.dateReceived.formatted(date: .abbreviated, time: .omitted))",
                    icon: "dollarsign.circle",
                    color: .green
                )
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    DashboardView(dataManager: DataManager())
} 