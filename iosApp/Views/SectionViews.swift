import SwiftUI
import Shared

/// Section title marked as a header, so VoiceOver's rotor can jump between sections.
struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.title2.bold())
            .labelStyle(SectionLabelStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.xLarge)
            .padding(.bottom, Spacing.small)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct SectionLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Spacing.xSmall) {
            configuration.icon.foregroundStyle(Color.accentColor).font(.title3)
            configuration.title
        }
    }
}

/// Non-interactive label. Deliberately not a button, so it doesn't look tappable.
struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, Spacing.small)
            .padding(.vertical, 6)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct EducationCard: View {
    let education: Education

    var body: some View {
        HStack(spacing: Spacing.small) {
            LogoView(url: education.resolvedLogoUrl, name: education.schoolName)
            VStack(alignment: .leading, spacing: 2) {
                Text(education.schoolName).font(.headline)
                Text("\(education.degree) · \(education.fieldOfStudy)").font(.subheadline)
                Text(education.period.displayText).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer(minLength: Spacing.xSmall)
            if let urlString = education.url, let url = URL(string: urlString) {
                Link(destination: url) {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Open \(education.schoolName) website")
            }
        }
        .padding(.leading, Spacing.medium)
        .padding(.trailing, Spacing.xSmall)
        .padding(.vertical, Spacing.medium)
        .cardStyle()
    }
}

struct FooterView: View {
    var body: some View {
        Text("Built with SwiftUI and Kotlin Multiplatform")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xLarge)
    }
}

/// Wrapping row layout for tags and buttons.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(width maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let extra = rows[rows.count - 1].indices.isEmpty ? size.width : size.width + spacing
            if rows[rows.count - 1].width + extra > maxWidth, !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            let isFirst = rows[rows.count - 1].indices.isEmpty
            rows[rows.count - 1].indices.append(index)
            rows[rows.count - 1].width += isFirst ? size.width : size.width + spacing
            rows[rows.count - 1].height = max(rows[rows.count - 1].height, size.height)
        }
        return rows.filter { !$0.indices.isEmpty }
    }
}
