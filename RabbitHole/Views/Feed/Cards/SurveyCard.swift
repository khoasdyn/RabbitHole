import SwiftUI

struct SurveyCard: View {

    let item: ContentItem
    @State private var selectedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            typeBadge

            Text(item.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)

            if let parsed = parsedData {
                VStack(spacing: 8) {
                    ForEach(parsed.options.indices, id: \.self) { i in
                        if selectedIndex != nil {
                            resultRow(option: parsed.options[i], percent: parsed.percents[i], isSelected: i == selectedIndex)
                        } else {
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedIndex = i
                                    item.isCompleted = true
                                }
                            } label: {
                                Text(parsed.options[i])
                                    .font(.caption)
                                    .foregroundStyle(Color(.label))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(.tertiarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
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

    // MARK: - Result row

    private func resultRow(option: String, percent: Int, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(option)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(Color(.label))
                Spacer()
                Text("\(percent)%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? ContentType.survey.color : Color(.secondaryLabel))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemBackground))
                        .frame(height: 6)

                    Capsule()
                        .fill(isSelected ? ContentType.survey.color : Color(.quaternaryLabel))
                        .frame(width: geo.size.width * CGFloat(percent) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(isSelected ? ContentType.survey.color.opacity(0.08) : Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Parsing

    private var typeBadge: some View {
        Label(ContentType.survey.label, systemImage: ContentType.survey.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.survey.color)
    }

    private var parsedData: SurveyData? {
        guard let body = item.body,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let options = json["options"] as? [String],
              let results = json["results"] as? [Int] else {
            return nil
        }
        let total = results.reduce(0, +)
        let percents = results.map { total > 0 ? Int(round(Double($0) / Double(total) * 100)) : 0 }
        return SurveyData(options: options, percents: percents)
    }
}

private struct SurveyData {
    let options: [String]
    let percents: [Int]
}
