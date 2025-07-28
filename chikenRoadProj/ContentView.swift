import SwiftUI

struct ContentView: View {
    @StateObject private var diaryManager = ChickenDiaryManager()
    
    var body: some View {
        TabView {
            ChickenGroupsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("My Chickens")
                }
            
            DiaryListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Diary")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Statistics")
                }
        }
        .environmentObject(diaryManager)
        .accentColor(.orange)
    }
}

#Preview {
    ContentView()
}
