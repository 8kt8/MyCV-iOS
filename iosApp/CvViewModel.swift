import Foundation
import Shared

/// Offline-first: shows the CV bundled from cv.json immediately, then refreshes it from GitHub.
/// Kotlin suspend functions are called on the main actor, as Kotlin/Native requires by default.
@MainActor
final class CvViewModel: ObservableObject {
    @Published private(set) var cv: Cv?
    @Published var refreshError: String?

    private let service = CvService()

    func load() async {
        if cv == nil {
            cv = try? await service.bundledCv()
        }
        await refresh(userInitiated: false)
    }

    func refresh(userInitiated: Bool) async {
        do {
            cv = try await service.latestCv()
        } catch {
            // Keep the content we already show; only tell the user when they asked for the refresh.
            if userInitiated {
                refreshError = "Couldn't refresh - showing the saved CV"
            }
        }
    }

    deinit {
        service.close()
    }
}
