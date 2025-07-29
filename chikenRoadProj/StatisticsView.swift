import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var diaryManager: PigeonDiaryManager
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if diaryManager.diaryEntries.isEmpty {
                        emptyStateView
                    } else {
                        statisticsCards
                        calendarView
                        groupStatistics
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
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
                icon: "bird",
                color: .blue
            )
            
            StatCard(
                title: "Average Mood",
                value: diaryManager.getAverageMood().rawValue,
                icon: diaryManager.getAverageMood().icon,
                color: moodColor(diaryManager.getAverageMood())
            )
            
            StatCard(
                title: "Total Entries",
                value: "\(diaryManager.diaryEntries.count)",
                icon: "book.fill",
                color: .orange
            )
            
            StatCard(
                title: "Pigeon Groups",
                value: "\(diaryManager.pigeonGroups.count)",
                icon: "house.fill",
                color: .blue
            )
        }
    }
    
    private var calendarView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Calendar")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            CalendarGridView(
                selectedDate: $selectedDate,
                daysWithEntries: diaryManager.getDaysWithEntries()
            )
        }
        .background(Color(.systemBackground))
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
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
            // Month and year header
            HStack {
                Text(monthYearString)
                    .font(.headline)
                Spacer()
                HStack(spacing: 16) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding(.horizontal)
            
            // Day of week headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(textColor)
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .orange
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
