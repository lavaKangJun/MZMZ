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
import DustListView

struct Provider: TimelineProvider {
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
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do {
                var items: [LocationInfo] = []
                let dustInfos = self.usecase.getDustInfo()
                let dataModels = try await withThrowingTaskGroup(of: LocationInfo.self) { group in
                    for (index, dustInfo) in dustInfos.enumerated() {
                        group.addTask {
                            guard let latitude = Double(dustInfo.latitude),
                                  let longtitude = Double(dustInfo.longitude),
                                  let location = try await self.usecase.convertoToTMCoordinate(latitude: latitude, longtitude: longtitude),
                                  let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return LocationInfo(location: dustInfo.location, dustText: "", microText: "") }
                            
                            return LocationInfo(location: dustInfo.location, dustText: mesureDnsty.dustGradeText, microText: mesureDnsty.microDustGradeText)
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
        VStack(alignment: .leading, spacing: 5) {
            ForEach(entry.items) { info in
                HStack {
                    Text(info.location)
                    Text("미세: \(info.dustText)")
                    Text("초미세: \(info.microText)")
                }
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
