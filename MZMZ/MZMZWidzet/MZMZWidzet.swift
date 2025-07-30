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
    private let dustListSubject = CurrentValueSubject<[SimpleEntry], Never>([])
    
    init(usecase: DustListUseCaseProtocol) {
        self.usecase = usecase
    }
    
    public var dustListStream: AnyPublisher<[SimpleEntry], Never> {
        return self.dustListSubject.eraseToAnyPublisher()
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(location: "loaction", dustText: "좋음", microText: "나쁨")
    }

    // 빠르게 보일 임시 데이터 제공
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(location: "천호동", dustText: "좋음", microText: "나쁨")
        completion(entry)
    }

    // 실제 데이터 fetch해서 보여주는 부분
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            do {
                var result: [SimpleEntry] = []
                let dustInfos = self.usecase.getDustInfo()
                let dataModels = try await withThrowingTaskGroup(of: SimpleEntry.self) { group in
                    for (index, dustInfo) in dustInfos.enumerated() {
                        group.addTask {
                            guard let latitude = Double(dustInfo.latitude),
                                  let longtitude = Double(dustInfo.longitude),
                                  let location = try await self.usecase.convertoToTMCoordinate(latitude: latitude, longtitude: longtitude),
                                  let mesureDnsty = try await self.usecase.fetchMesureDnsty(tmX: location.x, tmY: location.y) else { return SimpleEntry(location: dustInfo.location, dustText: "", microText: "") }
                            
                            return SimpleEntry(location: dustInfo.location, dustText: mesureDnsty.dustGradeText, microText: mesureDnsty.microDustGradeText)
                        }
                    }
                    
                    for try await model in group {
                        print("result", model)
                        result.append(model)
                    }
                    return result.first
                }
                let timeline = Timeline(entries: result, policy: .atEnd)
                completion(timeline)
         
            } catch {
                print("error", error)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let location: String
    let dustText: String
    let microText: String
    
    init(location: String, dustText: String, microText: String) {
        self.date = Date()
        self.location = location
        self.dustText = dustText
        self.microText = microText
    }
}

struct MZMZWidzetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.location)
            Text("미세먼지: \(entry.dustText)")
            Text("초미세먼지: \(entry.microText)")
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
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}

#Preview(as: .systemSmall) {
    MZMZWidzet()
} timeline: {
    SimpleEntry(location: "천호동", dustText: "", microText: "")
}
