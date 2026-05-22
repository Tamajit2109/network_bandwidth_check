import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: SpeedTestViewModel

    var body: some View {
        VStack(spacing: 24) {
            if model.isRunning {
                ProgressView("Testing…")
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let metrics = model.metrics {
                results(metrics)
            }

            if let error = model.errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task { await model.runTest() }
            } label: {
                Text(model.isRunning ? "Testing…" : "Run Speed Test")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(model.isRunning)
            .keyboardShortcut(.defaultAction)
        }
        .padding(32)
        .frame(width: 320, height: 300)
    }

    private func results(_ metrics: SpeedTestMetrics) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            row("Download", String(format: "%.2f Mbps", metrics.downloadMbps))
            row("Upload", String(format: "%.2f Mbps", metrics.uploadMbps))
            row("Ping", String(format: "%.2f ms", metrics.pingMs))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func row(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title.bold().monospacedDigit())
        }
    }
}
