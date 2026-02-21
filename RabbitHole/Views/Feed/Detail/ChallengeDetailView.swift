import SwiftUI

struct ChallengeDetailView: View {
    let item: ContentItem
    @Environment(\.dismiss) private var dismiss
    @State private var userInput = ""
    @State private var isCompleted = false

    private var instructions: String {
        guard let body = item.body,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let text = json["instructions"] as? String else {
            return item.subtitle ?? ""
        }
        return text
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TypeBadge(type: .challenge)

                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.label))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(instructions)
                        .font(.body)
                        .foregroundStyle(Color(.secondaryLabel))
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    if !isCompleted {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your response")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(.tertiaryLabel))

                            TextField("Write here...", text: $userInput, axis: .vertical)
                                .font(.body)
                                .lineLimit(4...10)
                                .padding(CardStyle.padding)
                                .background(Color(.tertiarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 4)

                        Button {
                            withAnimation {
                                isCompleted = true
                                item.isCompleted = true
                            }
                        } label: {
                            Text("Complete Challenge")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, CardStyle.padding)
                                .background(
                                    userInput.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? Color(.tertiarySystemBackground)
                                        : ContentType.challenge.color
                                )
                                .foregroundStyle(
                                    userInput.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? Color(.tertiaryLabel)
                                        : .white
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    } else {
                        completedBanner
                    }
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

    private var completedBanner: some View {
        VStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(ContentType.challenge.color)
            Text("Challenge complete")
                .font(.headline)
                .foregroundStyle(Color(.label))
            Text("Nice work. This kind of practice is how ideas stick.")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(ContentType.challenge.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
    }
}
