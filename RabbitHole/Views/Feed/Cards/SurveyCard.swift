import SwiftUI

struct SurveyCard: View {

    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            typeBadge

            Text(item.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)

            // Show options inline
            if let options = parsedOptions {
                VStack(spacing: 8) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                            .font(.caption)
                            .foregroundStyle(Color(.label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var typeBadge: some View {
        Label(ContentType.survey.label, systemImage: ContentType.survey.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.survey.color)
    }

    private var parsedOptions: [String]? {
        guard let body = item.body,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let options = json["options"] as? [String] else {
            return nil
        }
        return options
    }
}
