import SwiftUI
import Shared

/// One entry of the experience timeline: logo on a vertical rail, details in a card.
struct ExperienceItemView: View {
    let experience: Experience
    let isLast: Bool

    private let logoSize: CGFloat = 48

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.small) {
            LogoView(url: experience.resolvedLogoUrl, name: experience.companyName, size: logoSize)
            ExperienceCard(experience: experience)
                .padding(.bottom, isLast ? 0 : Spacing.medium)
        }
        .background(alignment: .topLeading) {
            if !isLast {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 2)
                    .padding(.top, logoSize + Spacing.xxSmall)
                    .padding(.leading, logoSize / 2 - 1)
            }
        }
    }
}

private struct ExperienceCard: View {
    let experience: Experience
    @State private var isExpanded = false

    private var hasDetails: Bool { !experience.highlights.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(experience.role)
                        .font(.headline)
                    Text(experience.companyName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.accentColor)
                }
                Spacer(minLength: Spacing.xSmall)
                if let urlString = experience.companyUrl, let url = URL(string: urlString) {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.body)
                            .foregroundStyle(Color(.secondaryLabel))
                            .frame(width: 44, height: 44)
                    }
                    .padding(.top, -Spacing.small)
                    .padding(.trailing, -Spacing.small)
                    .accessibilityLabel("Open \(experience.companyName) website")
                }
            }

            if experience.period.isCurrent {
                Text("Current")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, Spacing.xSmall)
                    .padding(.vertical, 3)
                    .foregroundStyle(Color.accentColor)
                    .background(Color.accentColor.opacity(0.15), in: Capsule())
            }

            Text([experience.period.displayText, experience.location].compactMap { $0 }.joined(separator: "  ·  "))
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let summary = experience.summary {
                Text(summary)
                    .font(.subheadline)
                    .padding(.top, Spacing.xxSmall)
            }

            // Always visible: the tech stack is what people skim a CV for.
            if !experience.techStack.isEmpty {
                Text(experience.techStack.joined(separator: " · "))
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            }

            if isExpanded {
                details
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if !experience.apps.isEmpty {
                FlowLayout(spacing: Spacing.xSmall) {
                    ForEach(Array(experience.apps.enumerated()), id: \.offset) { _, app in
                        StoreButton(app: app)
                    }
                }
                .padding(.top, Spacing.xxSmall)
            }

            if hasDetails {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
                } label: {
                    HStack(spacing: Spacing.xxSmall) {
                        Text(isExpanded ? "Hide details" : "Show details")
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .font(.subheadline.weight(.semibold))
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.medium)
        .padding(.bottom, hasDetails ? Spacing.xxSmall : Spacing.medium)
        .cardStyle()
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            ForEach(experience.highlights, id: \.self) { highlight in
                HStack(alignment: .firstTextBaseline, spacing: Spacing.xSmall) {
                    Text("•").foregroundStyle(Color.accentColor)
                    Text(highlight)
                }
                .font(.subheadline)
            }
        }
        .padding(.top, Spacing.xxSmall)
    }
}

private struct StoreButton: View {
    let app: AppLink

    var body: some View {
        if let url = URL(string: app.url) {
            Link(destination: url) {
                HStack(spacing: Spacing.xSmall) {
                    storeIcon
                        .frame(width: 18, height: 18)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(storeName).font(.caption2)
                        Text(app.name).font(.subheadline.weight(.semibold))
                    }
                }
                .padding(.horizontal, Spacing.small)
                .padding(.vertical, 6)
                .frame(minHeight: 44)
                .overlay(Capsule().stroke(Color.accentColor.opacity(0.5)))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Get \(app.name) on \(storeName)")
            .accessibilityAddTraits(.isLink)
        }
    }

    private var storeName: String {
        switch app.store {
        case .googleplay: "Google Play"
        case .appstore: "App Store"
        default: "Web"
        }
    }

    @ViewBuilder private var storeIcon: some View {
        switch app.store {
        case .googleplay: Image("googleplay").resizable().scaledToFit()
        case .appstore: Image("appstore").resizable().scaledToFit()
        default: Image(systemName: "globe").resizable().scaledToFit()
        }
    }
}
