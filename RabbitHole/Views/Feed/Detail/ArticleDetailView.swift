import SwiftUI

struct ArticleDetailView: View {

    let item: ContentItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Meta
                    HStack {
                        Label(ContentType.article.label, systemImage: ContentType.article.iconName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(ContentType.article.color)
                        Spacer()
                        if let minutes = item.estimatedMinutes {
                            Text("\(minutes) min read")
                                .font(.caption)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                    }

                    // Title
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.label))
                        .fixedSize(horizontal: false, vertical: true)

                    // Subtitle
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color(.secondaryLabel))
                    }

                    Spacer().frame(height: 4)

                    // Body
                    if let body = item.body {
                        Text(body)
                            .font(.body)
                            .foregroundStyle(Color(.label))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer().frame(height: 24)

                    // Done button
                    Button {
                        item.isCompleted = true
                        dismiss()
                    } label: {
                        Label(
                            item.isCompleted ? "Read" : "Mark as Read",
                            systemImage: item.isCompleted ? "checkmark.circle.fill" : "checkmark.circle"
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundStyle(item.isCompleted ? Color(.tertiaryLabel) : ContentType.article.color)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
