import SwiftUI

struct ContentView: View {
    @StateObject private var diaryManager = PigeonDiaryManager()
    
    var body: some View {
        TabView {
            PigeonGroupsView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("My Pigeons")
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
