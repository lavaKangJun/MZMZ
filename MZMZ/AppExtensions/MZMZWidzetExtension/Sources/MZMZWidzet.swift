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
        let location = LocationInfo(location: "loaction", dustText: "좋음", microText: "나쁨")
        return SimpleEntry(items: [location])
    }

    // 빠르게 보일 임시 데이터 제공
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let location = LocationInfo(location: "천호동", dustText: "좋음", microText: "나쁨")
        let entry = SimpleEntry(items: [location])
        completion(entry)
    }

    // 실제 데이터 fetch해서 보여주는 부분
    nonisolated func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> ()) {
        Task {
            do {
                var items: [LocationInfo] = []
                let dustInfos = try self.usecase.getDustInfo()
                // 즐겨찾기된 지역들만 필터링 (최대 2개)
                let favoriteInfos = dustInfos.filter { $0.isFavorite }
                let dataModels = try await withThrowingTaskGroup(of: LocationInfo.self) { group in
                    for (index, dustInfo) in favoriteInfos.enumerated() {
                        group.addTask {
                            let entity = LocationInfoEntity(latitude: dustInfo.latitude, longtitude: dustInfo.longitude)
                            guard let location = try await self.usecase.convertoToTMCoordinate(location: entity),
                                  let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return LocationInfo(location: dustInfo.location, dustText: "", microText: "") }
                            
                            return LocationInfo(
                                location: dustInfo.location,
                                dustText:
                                    AirQualityGrade.grade(forPM10: mesureDnsty.pm10Value).rawValue,
                                microText: AirQualityGrade.grade(forPM25: mesureDnsty.pm10Value).rawValue
                            )
                        }
                    }
                    
                    for try await model in group {
                        print("result", model)
                        items.append(model)
                    }
                    return items
                }
                let timeline = Timeline(entries: [SimpleEntry(items: items)], policy: .after(Date().addingTimeInterval(600)))
                completion(timeline)
         
            } catch {
                print("error", error)
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
    
    init(location: String, dustText: String, microText: String) {
        self.location = String(location.split(separator: " ").last ?? "")
        self.dustText = dustText
        self.microText = microText
    }
}

struct MZMZWidzetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry

    var body: some View {
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
                        .font(.system(size: 9, weight: .medium))
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                )
            }
        }
        .font(Font.system(size: 11, weight: .semibold))
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
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    MZMZWidzet()
} timeline: {
    SimpleEntry(items: [LocationInfo(location: "천호동", dustText: "", microText: "")])
}
