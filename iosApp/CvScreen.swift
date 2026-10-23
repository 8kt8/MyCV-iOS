import SwiftUI
import Shared

struct CvScreen: View {
    @StateObject private var viewModel = CvViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let cv = viewModel.cv {
                    CvContent(cv: cv)
                        .refreshable { await viewModel.refresh(userInitiated: true) }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .task { await viewModel.load() }
        .overlay(alignment: .bottom) {
            if let message = viewModel.refreshError {
                ToastView(message: message)
                    .task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        withAnimation { viewModel.refreshError = nil }
                    }
            }
        }
        .animation(.default, value: viewModel.refreshError)
    }
}

private struct CvContent: View {
    let cv: Cv

    /// Content top at rest, in the scroll view's coordinate space (the bar's bottom edge).
    @State private var restingTop: CGFloat?
    @State private var titleBottom: CGFloat = .infinity
    @State private var isScrolled = false
    /// True once the name in the header has scrolled under the navigation bar.
    @State private var showsTitle = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScrollOffsetReader()
                ProfileHeaderView(profile: cv.profile, contacts: cv.contacts)

                Group {
                    if !cv.experience.isEmpty {
                        SectionHeader(title: "Experience", systemImage: "briefcase.fill")
                        ForEach(Array(cv.experience.enumerated()), id: \.offset) { index, experience in
                            ExperienceItemView(experience: experience, isLast: index == cv.experience.count - 1)
                        }
                    }
                    if !cv.skills.isEmpty {
                        SectionHeader(title: "Skills", systemImage: "chevron.left.forwardslash.chevron.right")
                        FlowLayout(spacing: Spacing.xSmall) {
                            ForEach(cv.skills, id: \.self) { TagView(text: $0) }
                        }
                    }
                    if !cv.education.isEmpty {
                        SectionHeader(title: "Education", systemImage: "graduationcap.fill")
                        VStack(spacing: Spacing.small) {
                            ForEach(Array(cv.education.enumerated()), id: \.offset) { _, education in
                                EducationCard(education: education)
                            }
                        }
                    }
                    FooterView()
                }
                .padding(.horizontal, Spacing.medium)
            }
            .frame(maxWidth: Metrics.maxContentWidth)
            .frame(maxWidth: .infinity)
        }
        // Header gradient also fills the area behind the bars and the rubber-band overscroll.
        .background(alignment: .top) {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.22), Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 520)
            .ignoresSafeArea(edges: .top)
        }
        .coordinateSpace(name: CvScrollSpace.name)
        .onPreferenceChange(ScrollOffsetKey.self) { top in
            if restingTop == nil { restingTop = top }
            let rest = restingTop ?? top
            updateBar(isScrolled: top < rest - 8, showsTitle: titleBottom < rest)
        }
        .onPreferenceChange(HeaderTitleBottomKey.self) { bottom in
            titleBottom = bottom
            guard let rest = restingTop else { return }
            updateBar(isScrolled: isScrolled, showsTitle: bottom < rest)
        }
        // Standard navigation bar: Liquid Glass on iOS 26+, the bar material on earlier versions.
        // The name and a contact menu appear in it once the header has scrolled away.
        .navigationTitle(showsTitle ? cv.profile.fullName : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if showsTitle && !cv.contacts.isEmpty {
                    ContactMenu(contacts: cv.contacts)
                }
            }
        }
        .navigationBarScrim(visible: isScrolled)
    }

    private func updateBar(isScrolled scrolled: Bool, showsTitle title: Bool) {
        guard scrolled != isScrolled || title != showsTitle else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            isScrolled = scrolled
            showsTitle = title
        }
    }
}

/// All contact actions in one toolbar menu, for when the header's buttons are scrolled away.
private struct ContactMenu: View {
    let contacts: [ContactLink]

    var body: some View {
        Menu {
            ForEach(Array(contacts.enumerated()), id: \.offset) { _, contact in
                if let url = URL(string: contact.url) {
                    Link(destination: url) {
                        Label { Text(contact.displayTitle) } icon: { contact.icon }
                    }
                }
            }
        } label: {
            Label("Contact", systemImage: "envelope")
        }
    }
}

enum CvScrollSpace {
    static let name = "cvScroll"
}

/// Reports the scroll offset on iOS 16 (onScrollGeometryChange needs iOS 18).
private struct ScrollOffsetReader: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: ScrollOffsetKey.self,
                value: proxy.frame(in: .named(CvScrollSpace.name)).minY
            )
        }
        .frame(height: 0)
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

struct HeaderTitleBottomKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = min(value, nextValue()) }
}

extension View {
    /// Reports this view's bottom edge in the CV scroll view, so the bar can show the name once it scrolls away.
    func reportsHeaderTitleBottom() -> some View {
        background {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: HeaderTitleBottomKey.self,
                    value: proxy.frame(in: .named(CvScrollSpace.name)).maxY
                )
            }
        }
    }

    /// Below iOS 26 the bar is transparent over the header and gets its material once content scrolls under it.
    /// On iOS 26+ the system's scroll edge effect handles legibility, so the bar is left as the system draws it.
    @ViewBuilder
    func navigationBarScrim(visible: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            toolbarBackground(visible ? .visible : .hidden, for: .navigationBar)
        }
    }
}

/// Transient message floating above the content: Liquid Glass on iOS 26+, a material capsule before.
private struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .toastBackground()
            .padding(.bottom, Spacing.large)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .accessibilityAddTraits(.isStaticText)
    }
}

private extension View {
    @ViewBuilder
    func toastBackground() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular, in: Capsule())
        } else {
            background(.regularMaterial, in: Capsule())
        }
    }
}
