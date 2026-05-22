import SwiftUI
import WidgetKit

struct BandwidthEntry: TimelineEntry {
    let date: Date
    let metrics: SpeedTestMetrics?
}

struct BandwidthProvider: TimelineProvider {
    func placeholder(in context: Context) -> BandwidthEntry {
        BandwidthEntry(
            date: .now,
            metrics: SpeedTestMetrics(pingMs: 10, downloadMbps: 200, uploadMbps: 30)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BandwidthEntry) -> Void) {
        completion(BandwidthEntry(date: .now, metrics: AppGroupStorage.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BandwidthEntry>) -> Void) {
        let entry = BandwidthEntry(date: .now, metrics: AppGroupStorage.load())
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct BandwidthWidgetView: View {
    var entry: BandwidthEntry

    var body: some View {
        if let metrics = entry.metrics {
            VStack(alignment: .leading, spacing: 6) {
                Text("↓ \(formatMbps(metrics.downloadMbps)) Mbps")
                Text("↑ \(formatMbps(metrics.uploadMbps)) Mbps")
                Text("\(String(format: "%.0f", metrics.pingMs)) ms ping")
                    .foregroundStyle(.secondary)
            }
            .font(.caption.bold().monospacedDigit())
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            Text("Run a speed test in the app.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func formatMbps(_ value: Double) -> String {
        value >= 100 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}

struct BandwidthWidget: Widget {
    let kind = "BandwidthWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BandwidthProvider()) { entry in
            BandwidthWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Network Bandwidth")
        .description("Download, upload, and ping from your last test.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct BandwidthWidgetBundle: WidgetBundle {
    var body: some Widget {
        BandwidthWidget()
    }
}
