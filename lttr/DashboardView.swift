import SwiftUI

struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingSubscription = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if dataManager.isTrialExpired {
                        trialExpiredSection
                    } else if dataManager.userProfile.subscriptionType == .trial {
                        trialStatusSection
                    }
                    
                    todayPlanSection
                    nextWeekEarningsSection
                    recentActivitySection
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .sheet(isPresented: $showingSubscription) {
                SubscriptionView(dataManager: dataManager)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("lttr.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            
            Text("Letter Tracker")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
        }
        .padding(.top, 20)
    }
    
    private var trialStatusSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Trial Period")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("\(dataManager.daysLeftInTrial) days remaining")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
            }
            
            Spacer()
            
            Button("Upgrade") {
                showingSubscription = true
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var trialExpiredSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.4))
                Text("Trial Expired")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                Spacer()
            }
            
            Text("Upgrade to continue tracking your letter writing hustle")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                .multilineTextAlignment(.leading)
            
            Button("Upgrade Now") {
                showingSubscription = true
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var todayPlanSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Plan")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("\(dataManager.totalLettersSent)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                    Text("letters planted")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                }
                
                VStack(spacing: 8) {
                    Text("\(dataManager.totalResponsesReceived)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                    Text("done")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                }
                
                Spacer()
                
                Button("View Drops") {
                    // Navigate to responses
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var nextWeekEarningsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Next Week Earnings")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
            }
            
            HStack {
                Text("$\(String(format: "%.0f", dataManager.totalAmountReceived))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("ROI")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                    Text("\(String(format: "%.1f", dataManager.roi))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(dataManager.roi >= 0 ? Color(red: 0.3, green: 0.8, blue: 0.5) : Color(red: 1.0, green: 0.4, blue: 0.4))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
            
            if dataManager.letters.isEmpty && dataManager.responses.isEmpty {
                emptyStateView
            } else {
                activityListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(Color(red: 0.8, green: 0.8, blue: 0.85))
            
            VStack(spacing: 8) {
                Text("No activity yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text("Start by sending your first letter!")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var activityListView: some View {
        VStack(spacing: 12) {
            ForEach(dataManager.letters.prefix(3)) { letter in
                ActivityRow(
                    title: "Letter sent to \(letter.companyName)",
                    subtitle: letter.dateSent.formatted(date: .abbreviated, time: .omitted),
                    icon: "envelope.fill",
                    color: Color(red: 0.4, green: 0.6, blue: 1.0)
                )
            }
            
            ForEach(dataManager.responses.prefix(3)) { response in
                ActivityRow(
                    title: "Response from \(response.companyName)",
                    subtitle: "$\(String(format: "%.0f", response.amount)) • \(response.dateReceived.formatted(date: .abbreviated, time: .omitted))",
                    icon: "dollarsign.circle.fill",
                    color: Color(red: 0.3, green: 0.8, blue: 0.5)
                )
            }
        }
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
    }
}

struct SubscriptionView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Upgrade to Premium")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                        
                        Text("Unlock all features and continue tracking your success")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Pricing Tiers
                    VStack(spacing: 20) {
                        PricingCard(
                            title: "Monthly",
                            price: "$9.99",
                            period: "per month",
                            features: ["Unlimited letters", "All features", "Priority support"],
                            isPopular: false
                        )
                        
                        PricingCard(
                            title: "Yearly",
                            price: "$99.99",
                            period: "per year",
                            features: ["Unlimited letters", "All features", "Priority support", "Save 17%"],
                            isPopular: true
                        )
                    }
                    
                    // Terms
                    VStack(spacing: 12) {
                        Text("18+ verification required")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                        
                        Text("Terms of Service • Privacy Policy")
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                }
            }
        }
    }
}

struct PricingCard: View {
    let title: String
    let price: String
    let period: String
    let features: [String]
    let isPopular: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if isPopular {
                Text("MOST POPULAR")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(price)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                    Text(period)
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.55))
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.3, green: 0.8, blue: 0.5))
                        Text(feature)
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.25))
                    }
                }
            }
            
            Button("Choose \(title)") {
                // Handle subscription
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: isPopular ? 
                        [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.3, green: 0.5, blue: 0.9)] :
                        [Color(red: 0.6, green: 0.6, blue: 0.65), Color(red: 0.5, green: 0.5, blue: 0.55)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isPopular ? Color(red: 0.4, green: 0.6, blue: 1.0) : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    DashboardView(dataManager: DataManager())
} 