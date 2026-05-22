import SwiftUI

@main
struct NetworkBandwidthCheckApp: App {
    @StateObject private var viewModel = SpeedTestViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .defaultSize(width: 320, height: 300)

        MenuBarExtra("Bandwidth", systemImage: "speedometer") {
            MenuBarPanel()
                .environmentObject(viewModel)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarPanel: View {
    @EnvironmentObject private var model: SpeedTestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if model.isRunning {
                ProgressView("Testing…")
            } else if let metrics = model.metrics {
                Text("Download: \(String(format: "%.2f Mbps", metrics.downloadMbps))")
                Text("Upload: \(String(format: "%.2f Mbps", metrics.uploadMbps))")
                Text("Ping: \(String(format: "%.2f ms", metrics.pingMs))")
            }

            if let error = model.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await model.runTest() }
            } label: {
                Text(model.isRunning ? "Testing…" : "Run Speed Test")
            }
            .disabled(model.isRunning)
        }
        .padding(16)
        .frame(width: 220)
    }
}
