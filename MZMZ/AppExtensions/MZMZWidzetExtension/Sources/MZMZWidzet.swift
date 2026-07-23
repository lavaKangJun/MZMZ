//
//  MZMZWidzet.swift
//  MZMZWidzet
//
//  Created by 강준영 on 2025/04/16.
//

import WidgetKit
import SwiftUI
import Combine
import Domain
import Repository
import Common
//import DustListView

struct Provider: TimelineProvider, @unchecked Sendable {
    private let usecase: DustListUseCaseProtocol
    
    init(usecase: DustListUseCaseProtocol) {
        self.usecase = usecase
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        let location = LocationInfo(location: "loaction", pm10Grade: .checking, pm25Grade: .checking)
        return SimpleEntry(items: [location])
    }

    // 빠르게 보일 임시 데이터 제공
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let location = LocationInfo(location: "천호동", pm10Grade: .checking, pm25Grade: .checking)
        let entry = SimpleEntry(items: [location])
        completion(entry)
    }

    // 실제 데이터 fetch해서 보여주는 부분
    nonisolated func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> ()) {
        Task {
            do {
                let dustInfos = try self.usecase.getDustInfo()
                print("dustInfos", dustInfos)
                // 즐겨찾기된 지역들만 필터링 (최대 2개)
                let favoriteInfos = dustInfos.filter { $0.isFavorite }
                let items = try await withThrowingTaskGroup(of: (Int, LocationInfo).self) { group in
                    for (index, dustInfo) in favoriteInfos.enumerated() {
                        group.addTask {
                             let entity = LocationInfoEntity(latitude: dustInfo.latitude, longtitude: dustInfo.longitude)
                            guard let location = try await self.usecase.convertoToTMCoordinate(location: entity),
                                  let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return (index, LocationInfo(location: dustInfo.location, pm10Grade: .checking, pm25Grade: .checking)) }
                            
                            return (
                                index,
                                LocationInfo(
                                    location: dustInfo.location,
                                    pm10Grade:
                                        AirQualityGrade
                                        .grade(
                                            forPM10: mesureDnsty.pm10Value
                                        ),
                                    pm25Grade: AirQualityGrade
                                        .grade(
                                            forPM25: mesureDnsty.pm25Value
                                        )
                                )
                            )
                        }
                    }
                    
                    var collected: [(Int, LocationInfo)] = []
                    for try await model in group {
                        collected.append(model)
                    }
                    return collected
                }
                
                let refreshDate = Calendar.current.nextDate(
                    after: Date(),
                    matching: DateComponents(minute: 15),
                    matchingPolicy: .nextTime
                ) ?? Date().addingTimeInterval(3600)
                
                let sorted = items.sorted(by: { $0.0 < $1.0 }).map( { $0.1 })
                let timeline = Timeline(entries: [SimpleEntry(items: sorted)], policy: .after(refreshDate))
                completion(timeline)
                
            } catch {
                let favorites = (try? usecase.getDustInfo().filter { $0.isFavorite }) ?? []
                
                let items: [LocationInfo] = favorites.map {
                    LocationInfo(location: $0.location, pm10Grade: .checking, pm25Grade: .checking)
                }
                
                let timeline = Timeline(
                    entries: [SimpleEntry(items: items)],
                    policy: .after(Date().addingTimeInterval(3600))
                )
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [LocationInfo]
    
    init(items: [LocationInfo]) {
        self.date = Date()
        self.items = items
    }
}

struct LocationInfo: Identifiable {
    let id = UUID()
    let location: String
    let dustText: String
    let microText: String
    let pm10Grade: AirQualityGrade
    let pm25Grade: AirQualityGrade
    
    init(
        location: String,
        pm10Grade: AirQualityGrade,
        pm25Grade: AirQualityGrade
    ) {
        self.location = String(location.split(separator: " ").last ?? "")
        self.dustText = pm10Grade.rawValue
        self.microText = pm25Grade.rawValue
        self.pm10Grade = pm10Grade
        self.pm25Grade = pm25Grade
    }
}

struct MZMZWidzetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        switch widgetFamily {
        case .accessoryRectangular:
            lockScreenView
        case .systemSmall, .systemMedium:
            systemHomeView
        default:
            lockScreenView
        }
    }
    
    var emptyView: some View {
        VStack(spacing: 6) {
            Image(systemName: "plus.circle")
                .imageScale(.large)
                .font(.largeTitle)
                Text("즐겨찾기 지역을\n추가해주세요")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var systemHomeView: some View {
        Group {
            if entry.items.isEmpty {
                emptyView
            } else {
                VStack(spacing: 6) {
                    ForEach(entry.items) { info in
                        ZStack {
                            AirQualityCardBackground(
                                pm10Grade: info.pm10Grade,
                                pm25Grade: info.pm25Grade,
                                style: .list
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(info.location)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                                HStack(spacing: 4) {
                                    Text("미세 \(info.dustText)")
                                    Text("|")
                                    Text("초미세 \(info.microText)")
                                }
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }.padding(8)
    }
        
    var lockScreenView: some View {
        VStack(spacing: 2) {
            ForEach(entry.items) { info in
                HStack {
                    // 지역명
                    Text(info.location)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // 미세먼지 정보 (한 줄)
                    Text("미세: \(info.dustText) | 초미세: \(info.microText)")
                        .font(.system(size: 10, weight: .semibold))
                        .lineLimit(1)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                )
            }
        }
    }
}

struct MZMZWidzet: Widget {

    let kind: String = "MZMZWidzet"
    private let usecase: DustListUseCaseProtocol

    public init() {
        let repository = Repository(dataStore: DataStore.shared, remote: Remote())
        let locationService = LocationService()
        self.usecase = DustListUseCase(repository: repository, locationService: locationService)
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(usecase: usecase)) { entry in
            if #available(iOS 17.0, *) {
                MZMZWidzetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                MZMZWidzetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryRectangular,
                            .systemSmall,
                            .systemMedium
                           ])
    }
}

#Preview(as: .systemSmall) {
    MZMZWidzet()
} timeline: {
    SimpleEntry(items: [LocationInfo(location: "천호동", pm10Grade: .checking, pm25Grade: .checking)])
}
