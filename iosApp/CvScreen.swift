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
            .toolbar(.hidden, for: .navigationBar)
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
    @State private var isScrolled = false

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
        // Header gradient also fills the status bar area and rubber-band overscroll.
        .background(alignment: .top) {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.22), Color(.systemGroupedBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 520)
            .ignoresSafeArea(edges: .top)
        }
        .coordinateSpace(name: ScrollOffsetReader.space)
        .onPreferenceChange(ScrollOffsetKey.self) { offset in
            let scrolled = offset < -8
            if scrolled != isScrolled {
                withAnimation(.easeInOut(duration: 0.2)) { isScrolled = scrolled }
            }
        }
        // Status bar scrim once content scrolls underneath (the bar material, like a navigation bar).
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.bar)
                .frame(height: 0)
                .ignoresSafeArea(edges: .top)
                .opacity(isScrolled ? 1 : 0)
        }
    }
}

/// Reports the scroll offset on iOS 16 (onScrollGeometryChange needs iOS 18).
private struct ScrollOffsetReader: View {
    static let space = "cvScroll"

    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: ScrollOffsetKey.self,
                value: proxy.frame(in: .named(Self.space)).minY
            )
        }
        .frame(height: 0)
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(.regularMaterial, in: Capsule())
            .padding(.bottom, Spacing.large)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .accessibilityAddTraits(.isStaticText)
    }
}
