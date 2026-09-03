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
import MZMZTesting
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
                // 즐겨찾기된 지역들만 필터링 (최대 2개)
                let favoriteInfos = dustInfos.filter { $0.isFavorite }
                let expected = currentHourDataTime()
                // Bool = 이번 정시 값을 아직 못 받음(재시도 대상).
                let items = try await withThrowingTaskGroup(of: (Int, LocationInfo, Bool).self) { group in
                    for (index, dustInfo) in favoriteInfos.enumerated() {
                        group.addTask {
                            guard let dustDetailInfo = try? await self.usecase.nearestStationDustInfo(lat: dustInfo.latitude, lng: dustInfo.longitude) else {
                                return (index, LocationInfo(location: dustInfo.location, pm10Grade: .checking, pm25Grade: .checking), true)
                            }
                     
                            // 값이 null 인 경우뿐 아니라, 값은 정상인데 아직
                            // 이전 시각 것인 경우도 재시도 대상이다.
                            let needRetry = dustDetailInfo.dataTime != expected
                                || dustDetailInfo.pm10Value == nil
                                || dustDetailInfo.pm25Value == nil

                            return (
                                index,
                                LocationInfo(
                                    location: dustInfo.location,
                                    pm10Grade:
                                        AirQualityGrade
                                        .grade(
                                            forPM10: "\(dustDetailInfo.pm10Value ?? -1)"
                                        ),
                                    pm25Grade: AirQualityGrade
                                        .grade(
                                            forPM25: "\(dustDetailInfo.pm25Value ?? -1)"
                                        )
                                ),
                                needRetry
                            )
                        }
                    }
                    
                    var collected: [(Int, LocationInfo, Bool)] = []
                    for try await model in group {
                        collected.append(model)
                    }
                    return collected
                }
                
                let needsRetry = items.contains(where: { $0.2 })
                let refreshDate = nextRefreshDate(needsRetry: needsRetry)
                
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
    
    /// 서버가 내려주는 dataTime 은 "yyyy-MM-dd HH:mm" (KST) 형식이다.
    /// 지금 있어야 할 정시 문자열을 만들어 응답이 최신인지 비교하는 데 쓴다.
    private func currentHourDataTime(_ now: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd HH:00"
        return formatter.string(from: now)
    }

    /// 갱신을 시도할 분(分). 오름차순이어야 한다.
    ///
    /// 서버 쪽 일정과 맞물려 있다. 에어코리아가 14분 무렵에 시도 대부분을
    /// 올리고, 서버는 12분에 정기 수집한 뒤 16/20/30분에 보정한다.
    /// 실측상 16분 보정이 280~300개를 채우고 20분이 10~20개, 30분이 2~4개다.
    ///
    /// - 14분: 발행 직후. 이미 올라온 지역은 여기서 끝난다.
    /// - 18분: 16분 보정 직후. 대부분 여기서 채워진다.
    ///   (16분 보정은 16분 15초~48초에 끝나므로 18분이면 여유가 있다)
    /// - 23분: 20분 보정 직후.
    /// - 35분: 30분 보정 직후. 마지막 기회.
    private static let refreshMinutes = [14, 18, 23, 35]

    /// 다음 타임라인 갱신 시각.
    ///
    /// 받은 값이 이번 정시 것이면 다음 시각의 첫 슬롯으로 넘어간다.
    /// 낡았을 때만 같은 시각의 다음 슬롯으로 물러나며 다시 받아본다.
    /// 매번 네 번을 다 도는 게 아니라, 채워질 때까지만 쓰는 구조다.
    /// 필요 없는 호출을 만들지 않는 게 중요하다.
    ///
    private func nextRefreshDate(needsRetry: Bool, now: Date = Date()) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current

        let currentMinute = calendar.component(.minute, from: now)

        if needsRetry,
           let nextMinute = Self.refreshMinutes.first(where: { $0 > currentMinute }),
           let retry = calendar.nextDate(
            after: now,
            matching: DateComponents(minute: nextMinute),
            matchingPolicy: .nextTime
           ),
           calendar.component(.hour, from: retry)
            == calendar.component(.hour, from: now) {
            return retry
        }

        return calendar.nextDate(
            after: now,
            matching: DateComponents(minute: Self.refreshMinutes[0]),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(3600)
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
                                // Text 를 쪼개 HStack 으로 묶으면 안 된다.
                                // minimumScaleFactor 가 조각마다 따로 걸려
                                // 셋이 같은 비율로 줄지 않고, 폭이 모자라면
                                // 한 조각만 "…" 로 잘린다. 한 덩어리로 두면
                                // 문장 전체가 같은 비율로 축소된다.
                                //
                                // "매우나쁨"/"점검중" 은 "좋음" 보다 한 줄이
                                // 30pt 넘게 길어서 작은 위젯에서 넘친다.
                                // 여백을 줄여도 최소 폭 기기에선 모자라므로
                                // 줄바꿈 대신 축소되게 둔다.
                                
                                Text("미세 \(info.dustText)  |  초미세 \(info.microText)")
                                .font(.system(size: 10))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }.padding(6)
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
                        .minimumScaleFactor(0.8)
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
        #if DEBUG
        let isTesting = true
        #else
        let isTesting = false
        #endif

        if isTesting {
            self.usecase = StubDustListUseCase(
                repository: StubRepository(dataStore: FakeDataStore.shared)
            )
        } else {
            let repository = Repository(dataStore: DataStore.shared, remote: Remote())
            self.usecase = DustListUseCase(repository: repository)
        }
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
        .configurationDisplayName("미세먼지")
        .description("즐겨찾기한 지역의 미세먼지를 홈 화면에서 확인하세요.")
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
