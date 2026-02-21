import SwiftUI

struct QuizFlowView: View {

    let item: ContentItem
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var selectedAnswer: Int?
    @State private var hasAnswered = false
    @State private var correctCount = 0
    @State private var isFinished = false

    private var questions: [QuizQuestion] {
        guard let body = item.body,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let list = json["questions"] as? [[String: Any]] else {
            return []
        }
        return list.compactMap { dict in
            guard let q = dict["question"] as? String,
                  let opts = dict["options"] as? [String],
                  let correct = dict["correctIndex"] as? Int,
                  let explanation = dict["explanation"] as? String else { return nil }
            return QuizQuestion(question: q, options: opts, correctIndex: correct, explanation: explanation)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isFinished {
                    resultsView
                } else if questions.isEmpty {
                    Text("No questions available.")
                        .foregroundStyle(Color(.secondaryLabel))
                } else {
                    questionView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if !isFinished && !questions.isEmpty {
                        Text("\(currentIndex + 1) of \(questions.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Question

    private var questionView: some View {
        let q = questions[currentIndex]
        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(q.question)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 10) {
                    ForEach(q.options.indices, id: \.self) { i in
                        optionButton(index: i, question: q)
                    }
                }

                if hasAnswered {
                    Text(q.explanation)
                        .font(.subheadline)
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Button {
                        advance()
                    } label: {
                        Text(currentIndex < questions.count - 1 ? "Next" : "See Results")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ContentType.quiz.color)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private func optionButton(index: Int, question: QuizQuestion) -> some View {
        Button {
            guard !hasAnswered else { return }
            selectedAnswer = index
            hasAnswered = true
            if index == question.correctIndex {
                correctCount += 1
            }
        } label: {
            HStack {
                Text(question.options[index])
                    .font(.subheadline)
                    .foregroundStyle(Color(.label))
                    .multilineTextAlignment(.leading)
                Spacer()
                if hasAnswered {
                    if index == question.correctIndex {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else if index == selectedAnswer {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground(for: index, question: question))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor(for: index, question: question), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func cardBackground(for index: Int, question: QuizQuestion) -> Color {
        guard hasAnswered else { return Color(.tertiarySystemBackground) }
        if index == question.correctIndex { return .green.opacity(0.1) }
        if index == selectedAnswer { return .red.opacity(0.1) }
        return Color(.tertiarySystemBackground)
    }

    private func borderColor(for index: Int, question: QuizQuestion) -> Color {
        guard hasAnswered else { return .clear }
        if index == question.correctIndex { return .green.opacity(0.4) }
        if index == selectedAnswer { return .red.opacity(0.4) }
        return .clear
    }

    private func advance() {
        if currentIndex < questions.count - 1 {
            currentIndex += 1
            selectedAnswer = nil
            hasAnswered = false
        } else {
            item.isCompleted = true
            isFinished = true
        }
    }

    // MARK: - Results

    private var resultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: correctCount == questions.count ? "star.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(correctCount == questions.count ? .yellow : ContentType.quiz.color)

            Text("\(correctCount) out of \(questions.count)")
                .font(.title)
                .fontWeight(.bold)

            Text(resultMessage)
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ContentType.quiz.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    private var resultMessage: String {
        let ratio = questions.isEmpty ? 0 : Double(correctCount) / Double(questions.count)
        if ratio == 1 { return "Perfect score. You nailed every question." }
        if ratio >= 0.7 { return "Strong start. You've got the core ideas down." }
        return "Not bad for a first pass. The articles above cover what you missed."
    }
}

// MARK: - Model

private struct QuizQuestion {
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}
