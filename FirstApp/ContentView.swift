//
//  ContentView.swift
//  FirstApp
//
//  Created by Arsalan Lodhi on 4/17/25.
//

import SwiftUI
import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}




struct ContentView: View {
    @State private var notices: [Notice] = [
        Notice(title: "Newsletter", author: "Irom Sumiaya", date: "April 15, 2024", content: "Check out the latest edition of our weekly newsletter:"),
        Notice(title: "Field Trip Reminder", author: "Irom Karim", date: "April 12, 2024", content: "The 6th grade field trip to the museum is scheduled for April 18. Please ensure your child brings..."),
        Notice(title: "Parent-Teacher Conferences", author: "Irom Sumiaya", date: "April 8, 2024", content: "Join us for parent-teacher conferences on April 12–13. Schedule your appointment now."),
        Notice(title: "School Assembly", author: "", date: "April 4, 2024", content: "Don’t miss the school assembly happening this Friday.")
    ]
    
    @State private var question: String = ""
    @State private var aiResponse: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var scrollTarget: UUID? // for scroll behavior


    struct NoticeCardView: View {
        let notice: Notice

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                Text(notice.title)
                    .font(.headline)
                if !notice.author.isEmpty {
                    Text(notice.author)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Text(notice.date)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(notice.content)
                    .font(.body)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    struct MessageBubbleView: View {
        let message: ChatMessage

        var body: some View {
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                HStack {
                    if message.isUser {
                        Spacer()
                        Text(message.text)
                            .padding(12)
                            .background(Color(.systemGray5))
                            .foregroundColor(.black)
                            .cornerRadius(16)
                    } else {
                        Text(message.text)
                            .padding(.horizontal)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }

                Text(formattedDate(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(message.isUser ? .trailing : .leading, 12)
            }
            .padding(.horizontal)
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = message.text
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            }
        }

        private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }


    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Notices")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 10)

                        ForEach(notices) { notice in
                            NoticeCardView(notice: notice)
                        }

                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id) // 👈 for scrollTo
                        }


                    }
                    .padding()
                    .onChange(of: scrollTarget) { id in
                        if let id = id {
                            withAnimation {
                                proxy.scrollTo(id, anchor: .bottom)
                            }
                        }
                    }

                }
            }

            HStack {
                TextField("Ask AI Assistant", text: $question)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    sendQuestion()
                }) {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                }
                .padding(.leading, 4)
            }
            .padding()
        }
    }

    

    
    private func sendQuestion() {
        guard !question.isEmpty else { return }

        let userMessage = ChatMessage(text: question, isUser: true, timestamp: Date())
        messages.append(userMessage)
        scrollTarget = userMessage.id

        let sentText = question
        question = ""

        APIService.shared.askAI(question: sentText) { response in
            let aiMessage = ChatMessage(text: response, isUser: false, timestamp: Date())
            messages.append(aiMessage)
            scrollTarget = aiMessage.id
        }
    }


}
