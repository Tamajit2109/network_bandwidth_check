import Foundation

struct SpeedTestMetrics: Codable, Equatable {
    let pingMs: Double
    let downloadMbps: Double
    let uploadMbps: Double

    enum CodingKeys: String, CodingKey {
        case pingMs = "ping_ms"
        case downloadMbps = "download_mbps"
        case uploadMbps = "upload_mbps"
    }
}

enum AppGroup {
    static let identifier = "group.network.bandwidthcheck"
    static let lastResultKey = "lastSpeedTestResult"
}

enum AppGroupStorage {
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: AppGroup.identifier)
    }

    static func save(_ result: SpeedTestMetrics) {
        guard let defaults else { return }
        if let data = try? JSONEncoder().encode(result) {
            defaults.set(data, forKey: AppGroup.lastResultKey)
        }
    }

    static func load() -> SpeedTestMetrics? {
        guard let defaults,
              let data = defaults.data(forKey: AppGroup.lastResultKey) else {
            return nil
        }
        return try? JSONDecoder().decode(SpeedTestMetrics.self, from: data)
    }
}
