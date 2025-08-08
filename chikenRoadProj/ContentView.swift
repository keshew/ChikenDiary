import SwiftUI

struct ContentView: View {
    @StateObject private var diaryManager = PigeonDiaryManager()
    @State private var selectedTab: CustomTabBar.TabType = .Pigeons
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                if selectedTab == .Pigeons {
                    PigeonGroupsView()
                } else if selectedTab == .Diary {
                    DiaryListView()
                } else if selectedTab == .Statistics {
                    StatisticsView()
                }
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
        .environmentObject(diaryManager)
    }
}

#Preview {
    ContentView()
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabType
    
    enum TabType: Int {
        case Pigeons
        case Diary
        case Statistics
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Rectangle()
                    .fill(Color(red: 39/255, green: 17/255, blue: 25/255))
                    .frame(height: 110)
                    .edgesIgnoringSafeArea(.bottom)
                    .offset(y: 35)
                
                Rectangle()
                    .fill(Color(red: 71/255, green: 19/255, blue: 37/255))
                    .frame(height: 2)
                    .offset(y: -20)
            }
            
            HStack(spacing: 0) {
                TabBarItem(imageName: "tab1", tab: .Pigeons, selectedTab: $selectedTab)
                TabBarItem(imageName: "tab2", tab: .Diary, selectedTab: $selectedTab)
                TabBarItem(imageName: "tab3", tab: .Statistics, selectedTab: $selectedTab)
            }
            .padding(.top, 10)
            .frame(height: 60)
        }
    }
}

struct TabBarItem: View {
    let imageName: String
    let tab: CustomTabBar.TabType
    @Binding var selectedTab: CustomTabBar.TabType
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 12) {
                VStack {
                    Image(tab == selectedTab ? imageName + "Picked" : imageName)
                        .resizable()
                        .frame(
                            width: 24,
                            height: 24
                        )
                        .foregroundStyle(selectedTab == tab ? Color(red: 46/255, green: 115/255, blue: 211/255) : Color(red: 182/255, green: 188/255, blue: 196/255))
                    
                    Text("\(tab)")
                        .Pro(
                            size: 12,
                            color: selectedTab == tab
                            ? Color(red: 236/255, green: 192/255, blue: 22/255)
                            : Color(red: 134/255, green: 124/255, blue: 130/255)
                        )
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
