import SwiftUI

/// Remote logo or photo with a monogram placeholder while loading and when the URL is missing or broken.
/// Decorative: the name is always shown next to it, so it's hidden from VoiceOver.
struct LogoView: View {
    let url: String?
    let name: String
    var size: CGFloat = 48
    var isCircle = false
    /// Photos fill the frame; logos are fitted with a little padding on white.
    var isPhoto = false

    @StateObject private var loader = RemoteImageLoader()

    var body: some View {
        let shape = isCircle
            ? AnyShape(Circle())
            : AnyShape(RoundedRectangle(cornerRadius: size * 0.25, style: .continuous))

        Group {
            if let image = loader.image.map(Image.init(uiImage:)) {
                if isPhoto {
                    image.resizable().scaledToFill()
                } else {
                    image.resizable().scaledToFit().padding(size / 8).background(Color.white)
                }
            } else {
                monogram
            }
        }
        .frame(width: size, height: size)
        .task(id: url) { await loader.load(url.flatMap(URL.init(string:))) }
        .clipShape(shape)
        .overlay(shape.stroke(Color(.separator), lineWidth: 0.5))
        .accessibilityHidden(true)
    }

    private var monogram: some View {
        ZStack {
            Color.accentColor.opacity(0.15)
            Text(initials)
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.accentColor)
        }
    }

    private var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map { String($0).uppercased() }.joined()
    }
}
