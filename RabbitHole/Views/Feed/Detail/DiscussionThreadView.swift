import SwiftUI

struct DiscussionThreadView: View {

    let item: ContentItem
    @Environment(\.dismiss) private var dismiss

    @State private var visibleCount = 1
    @State private var userResponses: [Int: String] = [:]
    @State private var currentInput = ""
    @FocusState private var isInputFocused: Bool

    private var exchanges: [DiscussionExchange] {
        guard let body = item.body,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = json["exchanges"] as? [[String: Any]] else { return [] }
        return list.compactMap { dict in
            guard let role = dict["role"] as? String,
                  let text = dict["text"] as? String else { return nil }
            return DiscussionExchange(role: role, text: text)
        }
    }

    private var isFinished: Bool {
        visibleCount >= exchanges.count
    }

    private var needsUserInput: Bool {
        guard !isFinished else { return false }
        return userResponses[visibleCount] == nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(0..<visibleCount, id: \.self) { i in
                                if i < exchanges.count {
                                    messageBubble(for: exchanges[i], index: i)
                                }
                                if let response = userResponses[i + 1] {
                                    userBubble(text: response)
                                }
                            }

                            if isFinished {
                                completionBanner
                                    .id("bottom")
                            } else {
                                Spacer().frame(height: 1).id("bottom")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: visibleCount) {
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }

                if needsUserInput {
                    inputBar
                } else if isFinished {
                    doneBar
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Label(ContentType.discussion.label, systemImage: ContentType.discussion.iconName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(ContentType.discussion.color)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Bubbles

    private func messageBubble(for exchange: DiscussionExchange, index: Int) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "brain.head.profile")
                .font(.caption)
                .foregroundStyle(ContentType.discussion.color)
                .frame(width: 28, height: 28)
                .background(ContentType.discussion.color.opacity(0.15))
                .clipShape(Circle())

            Text(exchange.text)
                .font(.subheadline)
                .foregroundStyle(Color(.label))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func userBubble(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(ContentType.discussion.color)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var completionBanner: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(ContentType.discussion.color)
            Text("Discussion complete")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Share your thoughts...", text: $currentInput, axis: .vertical)
                .font(.subheadline)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($isInputFocused)

            Button {
                sendResponse()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        currentInput.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color(.tertiaryLabel)
                            : ContentType.discussion.color
                    )
            }
            .disabled(currentInput.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }

    private var doneBar: some View {
        Button {
            item.isCompleted = true
            dismiss()
        } label: {
            Text("Done")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(ContentType.discussion.color)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }

    private func sendResponse() {
        let trimmed = currentInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        userResponses[visibleCount] = trimmed
        currentInput = ""
        isInputFocused = false

        // Show next AI exchange after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                if visibleCount < exchanges.count {
                    visibleCount += 1
                }
            }
        }
    }
}

private struct DiscussionExchange {
    let role: String
    let text: String
}
