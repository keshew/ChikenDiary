import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(.back).resizable()
                .ignoresSafeArea()
            
            Image(.topLayer)
                .resizable()
                .frame(height: 150)
                .offset(y: -80)
            
     
                VStack(spacing: 24) {
                    HStack {
                        
                        Text("STATISTICS")
                            .Pro(size: 25, color: Color(red: 236/255, green: 192/255, blue: 22/255))
                            .shadow(radius: 1, y: 3)
                        
                    }
                    ScrollView(showsIndicators: false) {
                    if diaryManager.diaryEntries.isEmpty {
                        emptyStateView
                            .padding(.top)
                    } else {
                        statisticsCards
                            .padding(.top)
                        calendarView
                        
                        Color.clear.frame(height: 80)
//                        groupStatistics
                    }
                }
                .padding()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("No Statistics Yet!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add some diary entries to see your pigeon statistics!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var statisticsCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 20),
            GridItem(.flexible(), spacing: 20)
        ], spacing: 16) {
            StatCard(
                title: "Total Chicks",
                value: "\(diaryManager.getTotalChicks())",
                icon: "pigeon2",
                color: .blue,
                frahW: 33,
                fraH: 49
            )
            
            StatCard(
                title: "Average Mood",
                value: diaryManager.getAverageMood().rawValue,
                icon: diaryManager.getAverageMood().icon,
//                icon:"pigeon1",
                color: moodColor(diaryManager.getAverageMood()),
                frahW: 38,
                fraH: 38
            )
            
            StatCard(
                title: "Total Entries",
                value: "\(diaryManager.diaryEntries.count)",
                icon: "diary",
                color: .orange,
                frahW: 50,
                fraH: 38
            )
            
            StatCard(
                title: "Pigeon Groups",
                value: "\(diaryManager.pigeonGroups.count)",
                icon: "house",
                color: .blue,
                frahW: 35,
                fraH: 33
            )
        }
    }
    
    private var calendarView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ACTIVITY CALENDAR")
                .Pro(size: 15)
                .padding(.horizontal)
                .padding(.top)
            
            CalendarGridView(
                selectedDate: $selectedDate,
                daysWithEntries: diaryManager.getDaysWithEntries()
            )
        }
        .background(Color(red: 255/255, green: 219/255, blue: 102/255))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var groupStatistics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Group Performance")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            LazyVStack(spacing: 12) {
                ForEach(diaryManager.pigeonGroups) { group in
                    GroupStatRow(group: group)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func moodColor(_ mood: Mood) -> Color {
        switch mood {
        case .veryHappy: return .green
        case .happy: return .blue
        case .neutral: return .orange
        case .sad: return .yellow
        case .verySad: return .red
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let frahW: CGFloat
    let fraH: CGFloat
    var body: some View {
        Rectangle()
            .fill(Color(red: 255/255, green: 219/255, blue: 102/255))
        
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding()
            .background(Color(red: 255/255, green: 219/255, blue: 102/255))
            .cornerRadius(22)
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(.white, lineWidth: 2)
                    .overlay {
                        VStack(spacing: 3) {
                            Image(icon)
                                .resizable()
                                .frame(width: frahW, height: fraH)
                            
                            Text(value)
                                .Pro(size: 20)
                            
                            Text(title)
                                .Pro(size: 10, color: Color(red: 100/255, green: 100/255, blue: 100/255))
                                .multilineTextAlignment(.center)
                        }
                    }
            }
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let daysWithEntries: Set<Date>
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let weeksToShow = 6
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 5) {
                HStack(spacing: 16) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Text(monthYearString)
                        .Pro(size: 18)
                    
                    Spacer()
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.black)
                    }
                }
                
                Rectangle()
                    .fill(.white)
                    .frame(height: 1)
            }
            .padding(.horizontal)
            
            // Day of week headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .Pro(size: 16)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek), spacing: 4) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasEntry: daysWithEntries.contains(calendar.startOfDay(for: date))
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 32)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offsetDays = firstWeekday - calendar.firstWeekday
        let adjustedOffset = offsetDays < 0 ? offsetDays + 7 : offsetDays
        
        let startDate = calendar.date(byAdding: .day, value: -adjustedOffset, to: startOfMonth) ?? startOfMonth
        var days: [Date?] = []
        
        for i in 0..<(weeksToShow * daysInWeek) {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)
            days.append(date)
        }
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasEntry: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 32, height: 32)
            
            Text("\(calendar.component(.day, from: date))")
                .Pro(size: 13, color: isSelected ? .white : .black)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(textColor)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .black
        } else if hasEntry {
            return .orange.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if hasEntry {
            return .orange
        } else {
            return .primary
        }
    }
}

struct GroupStatRow: View {
    let group: PigeonGroup
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    
    private var groupEntries: [DiaryEntry] {
        diaryManager.getEntriesForGroup(group.id)
    }
    
    private var totalChicks: Int {
        groupEntries.reduce(0) { $0 + $1.chicksCount }
    }
    
    private var averageMood: Mood {
        let moodValues = groupEntries.map { entry -> Int in
            switch entry.mood {
            case .veryHappy: return 5
            case .happy: return 4
            case .neutral: return 3
            case .sad: return 2
            case .verySad: return 1
            }
        }
        
        let average = moodValues.isEmpty ? 3 : Double(moodValues.reduce(0, +)) / Double(moodValues.count)
        
        switch average {
        case 4.5...: return .veryHappy
        case 3.5..<4.5: return .happy
        case 2.5..<3.5: return .neutral
        case 1.5..<2.5: return .sad
        default: return .verySad
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                
                Text("\(group.pigeons.count) pigeon\(group.pigeons.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Image(systemName: "bird")
                        .foregroundColor(.blue)
                    Text("\(totalChicks)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: averageMood.icon)
                        .foregroundColor(moodColor(averageMood))
                    Text(averageMood.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func moodColor(_ mood: Mood) -> Color {
        switch mood {
        case .veryHappy: return .green
        case .happy: return .blue
        case .neutral: return .orange
        case .sad: return .yellow
        case .verySad: return .red
        }
    }
}

#Preview {
    StatisticsView()
        .environmentObject(PigeonDiaryManager())
} 
