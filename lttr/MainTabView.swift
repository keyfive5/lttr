import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            DashboardView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
            
            LettersView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "envelope.fill")
                    Text("Letters")
                }
            
            DropsView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Drops")
                }
            
            CasinosView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "building.2.fill")
                    Text("Casinos")
                }
            
            SettingsView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
} 