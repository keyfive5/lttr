import SwiftUI

struct MainTabView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            DashboardView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            LettersView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "envelope.fill")
                    Text("Letters")
                }
            
            ResponsesView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Drops")
                }
            
            SuppliesView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "shippingbox.fill")
                    Text("Tracker")
                }
            
            SettingsView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(Color(red: 0.4, green: 0.6, blue: 1.0))
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            
            // Normal state
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
            ]
            
            // Selected state
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)
            ]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
} 