//
//  StubDustListUseCase.swift
//  Testing
//
//  Created by 강준영 on 2025/03/29.
//

import Foundation
import Domain

public final class StubDustListUseCase: DustListUseCaseProtocol {
    private let repository: RepositoryProtocol

    /// 화면에 띄울 지역 한 곳.
    private struct Fixture {
        let location: String
        let station: String
        let latitude: String
        let longitude: String
        let isFavorite: Bool
        /// 미세먼지(PM10) 농도.
        let pm10: Int
        /// 초미세먼지(PM2.5) 농도.
        let pm25: Int
    }

    /// 등급이 골고루 보이도록 고른 값들.
    ///
    /// 경계는 `AirQualityGrade` 의 WHO 기준을 따른다.
    /// - PM10: 좋음 0~45 / 보통 46~50 / 주의 51~75 / 나쁨 76~100 / 매우나쁨 101~
    /// - PM2.5: 좋음 0~15 / 보통 16~25 / 주의 26~37 / 나쁨 38~50 / 매우나쁨 51~
    ///
    /// 즐겨찾기는 앞의 두 곳만 켰다. 실제 목록이 즐겨찾기를 위로 정렬하므로
    /// 배열 순서도 그에 맞췄다.
    private static let fixtures: [Fixture] = [
        // 미세 좋음(32) / 초미세 보통(21)
        Fixture(location: "서울 종로구 종로", station: "청계천로",
                latitude: "37.572025", longitude: "126.979166",
                isFavorite: true, pm10: 32, pm25: 21),
        // 미세 보통(48) / 초미세 매우나쁨(63)
        Fixture(location: "서울 강남구 역삼동", station: "강남대로",
                latitude: "37.500990", longitude: "127.036377",
                isFavorite: true, pm10: 48, pm25: 63),
        // 미세 나쁨(88) / 초미세 주의(33)
        Fixture(location: "부산 수영구 광안동", station: "광안동",
                latitude: "35.179554", longitude: "129.075642",
                isFavorite: false, pm10: 88, pm25: 33),
        // 미세 좋음(18) / 초미세 좋음(8)
        // 양쪽 다 좋음이면 카드에 햇살 오버레이가 붙는다
        // (AirQualityCardBackground.sunOverlay). 그 연출이 스크린샷에
        // 들어가도록 일부러 둘 다 좋음으로 뒀다.
        Fixture(location: "강원도 동해시", station: "천곡동",
                latitude: "37.524700", longitude: "129.114300",
                isFavorite: false, pm10: 18, pm25: 8),
    ]

    public init(repository: RepositoryProtocol) {
        self.repository = repository
    }

    public func nearestStationDustInfo(lat: String, lng: String) async throws -> DustInfoEntity {
        // 목록이 지역별로 좌표를 넘겨주므로 그걸로 어느 지역인지 가른다.
        let fixture = Self.fixtures.first {
            $0.latitude == lat && $0.longitude == lng
        } ?? Self.fixtures[0]

        return DustInfoEntity(
            stationName: fixture.station,
            pm10Value: fixture.pm10,
            pm25Value: fixture.pm25,
            // 위젯이 "이번 정시 값인가"를 dataTime 으로 판단한다.
            // 지난 시각으로 두면 계속 재시도하므로 현재 정시로 맞춘다.
            dataTime: Self.currentHourDataTime(),
            distanceKm: 1.2,
            sido: fixture.location,
            addr: fixture.station
        )
    }

    public func getDustInfo() -> [DustStoreEntity] {
        return Self.fixtures.map {
            DustStoreEntity(
                location: $0.location,
                longitude: $0.longitude,
                latitude: $0.latitude,
                isFavorite: $0.isFavorite
            )
        }
    }

    public func deleteDustInfo(location: String) -> Bool {
        return true
    }

    /// 에어코리아가 주는 형식("yyyy-MM-dd HH:00", KST)의 현재 정시.
    private static func currentHourDataTime(_ now: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd HH:00"
        return formatter.string(from: now)
    }
}
