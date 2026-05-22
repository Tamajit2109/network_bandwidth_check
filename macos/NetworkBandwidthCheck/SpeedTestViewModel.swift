import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class SpeedTestViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var metrics: SpeedTestMetrics?
    @Published var errorMessage: String?

    init() {
        metrics = AppGroupStorage.load()
    }

    func runTest(secure: Bool = true) async {
        guard !isRunning else { return }
        isRunning = true
        errorMessage = nil
        metrics = nil

        do {
            let newMetrics = try await SpeedTestRunner.run(secure: secure)
            metrics = newMetrics
            AppGroupStorage.save(newMetrics)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            errorMessage = error.localizedDescription
        }

        isRunning = false
    }
}
