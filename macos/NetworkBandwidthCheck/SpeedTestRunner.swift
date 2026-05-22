import Foundation

enum SpeedTestRunnerError: LocalizedError {
    case pythonNotFound
    case scriptNotFound
    case invalidOutput(String)
    case processFailed(String)

    var errorDescription: String? {
        switch self {
        case .pythonNotFound:
            "Python 3 not found. Install Python 3 and run: pip install -r requirements.txt"
        case .scriptNotFound:
            "wifi_speed_check.py not found in the app bundle."
        case .invalidOutput(let detail):
            "Could not read speed test results: \(detail)"
        case .processFailed(let message):
            message
        }
    }
}

enum SpeedTestRunner {
    private static let pythonCandidates = [
        "/opt/homebrew/bin/python3",
        "/usr/local/bin/python3",
        "/usr/bin/python3",
    ]

    static func findPython() -> URL? {
        for path in pythonCandidates where FileManager.default.isExecutableFile(atPath: path) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }

    static func scriptURL() -> URL? {
        if let bundled = Bundle.main.url(forResource: "wifi_speed_check", withExtension: "py") {
            return bundled
        }
        let repoScript = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("wifi_speed_check.py")
        if FileManager.default.fileExists(atPath: repoScript.path) {
            return repoScript
        }
        return nil
    }

    static func run(secure: Bool = true) async throws -> SpeedTestMetrics {
        guard let python = findPython() else { throw SpeedTestRunnerError.pythonNotFound }
        guard let script = scriptURL() else { throw SpeedTestRunnerError.scriptNotFound }

        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()
        process.executableURL = python
        process.currentDirectoryURL = script.deletingLastPathComponent()
        var environment = ProcessInfo.processInfo.environment
        environment["PYTHONUNBUFFERED"] = "1"
        process.environment = environment

        var args = [script.path, "--json"]
        if !secure {
            args.append("--insecure")
        }
        process.arguments = args
        process.standardOutput = stdout
        process.standardError = stderr

        return try await withCheckedThrowingContinuation { continuation in
            process.terminationHandler = { proc in
                let outData = stdout.fileHandleForReading.readDataToEndOfFile()
                let errData = stderr.fileHandleForReading.readDataToEndOfFile()
                let out = String(data: outData, encoding: .utf8) ?? ""
                let err = String(data: errData, encoding: .utf8) ?? ""

                guard proc.terminationStatus == 0 else {
                    let trimmedErr = err.trimmingCharacters(in: .whitespacesAndNewlines)
                    let message = trimmedErr.isEmpty
                        ? "Speed test exited with code \(proc.terminationStatus)"
                        : trimmedErr
                    continuation.resume(throwing: SpeedTestRunnerError.processFailed(message))
                    return
                }

                do {
                    let result = try parseJSON(from: out)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: SpeedTestRunnerError.processFailed(error.localizedDescription))
            }
        }
    }

    private static func parseJSON(from output: String) throws -> SpeedTestMetrics {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw SpeedTestRunnerError.invalidOutput("empty response")
        }

        let jsonBlob = extractJSONObject(from: trimmed) ?? trimmed
        guard let data = jsonBlob.data(using: .utf8) else {
            throw SpeedTestRunnerError.invalidOutput("invalid encoding")
        }

        do {
            return try JSONDecoder().decode(SpeedTestMetrics.self, from: data)
        } catch {
            throw SpeedTestRunnerError.invalidOutput(String(jsonBlob.prefix(200)))
        }
    }

    private static func extractJSONObject(from text: String) -> String? {
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else {
            return nil
        }
        return String(text[start...end])
    }
}
