import SwiftUI
import UIKit

/// Loads an image and treats non-2xx responses as failures.
/// (AsyncImage renders error bodies too - e.g. the favicon service's generic globe on a 404.)
@MainActor
final class RemoteImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?

    private static let cache = NSCache<NSURL, UIImage>()

    func load(_ url: URL?) async {
        guard let url else { image = nil; return }
        if let cached = Self.cache.object(forKey: url as NSURL) {
            image = cached
            return
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                  let loaded = UIImage(data: data) else { return }
            Self.cache.setObject(loaded, forKey: url as NSURL)
            image = loaded
        } catch {
            // Keep the placeholder.
        }
    }
}
