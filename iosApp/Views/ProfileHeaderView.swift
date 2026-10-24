import SwiftUI
import Shared

struct ProfileHeaderView: View {
    let profile: Profile
    let contacts: [ContactLink]

    @ScaledMetric(relativeTo: .largeTitle) private var avatarSize: CGFloat = 112

    var body: some View {
        VStack(spacing: Spacing.xSmall) {
            LogoView(url: profile.photoUrl, name: profile.fullName, size: avatarSize, isCircle: true, isPhoto: true)
                .padding(.bottom, Spacing.xSmall)

            Text(profile.fullName)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .reportsHeaderTitleBottom()

            Text(profile.headline)
                .font(.headline)
                .foregroundStyle(Color.accentColor)
                .multilineTextAlignment(.center)

            if let location = profile.location {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !contacts.isEmpty {
                HStack(alignment: .top, spacing: Spacing.large) {
                    ForEach(Array(contacts.enumerated()), id: \.offset) { _, contact in
                        ContactButton(contact: contact)
                    }
                }
                // Three round buttons have to fit side by side: cap their scaling (the rest of the page still scales).
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .padding(.top, Spacing.medium)
            }

            Text(profile.about)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.medium)
                .cardStyle()
                .padding(.top, Spacing.large)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Spacing.medium)
        .padding(.top, Spacing.xSmall) // sits right below the navigation bar
    }
}

/// Round action with a caption, like the actions on a Contacts card. Full label for VoiceOver.
private struct ContactButton: View {
    let contact: ContactLink

    @ScaledMetric private var circleSize: CGFloat = 56

    var body: some View {
        if let url = URL(string: contact.url) {
            Link(destination: url) {
                VStack(spacing: Spacing.xSmall) {
                    contact.icon
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: circleSize, height: circleSize)
                        .background(Color.accentColor.opacity(0.15), in: Circle())
                    Text(contact.displayTitle)
                        .font(.caption)
                        .foregroundStyle(Color(.secondaryLabel)) // explicit: Link would tint it
                }
                .frame(minWidth: 64)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(contact.displayTitle): \(contact.label)")
            .accessibilityAddTraits(.isLink)
        }
    }

}

extension ContactLink {
    /// Short name of the action, shared by the header buttons and the toolbar menu.
    var displayTitle: String {
        switch type {
        case .github: "GitHub"
        case .linkedin: "LinkedIn"
        case .email: "Email"
        case .phone: "Call"
        default: "Website"
        }
    }

    /// Plain image, as menus need it (they drop modified images).
    var iconImage: Image {
        switch type {
        case .github: Image("github")
        case .linkedin: Image("linkedin")
        case .email: Image(systemName: "envelope.fill")
        case .phone: Image(systemName: "phone.fill")
        default: Image(systemName: "globe")
        }
    }

    /// Icon that fills the frame it's given.
    var icon: some View {
        iconImage.resizable().scaledToFit()
    }
}
