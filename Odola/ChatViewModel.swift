//
//  ChatViewModel.swift
//  Odola
//
//  Created by Jian Ma on 12/22/24.
//
import Combine
import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(text: "Welcome! I am a chatbot that assists you with any questions you have. You can type '1. status of my transaction' to check your transaction status or '2. best time to send money to the Philippines' to get the best rates. Or simply their digits.", isUser: false)
    ]
    @Published var query: String = ""

    func sendMessage() {
        guard !query.isEmpty else { return }

        let userMessage = Message(text: query, isUser: true)
        DispatchQueue.main.async {
            self.messages.append(userMessage)
            self.query = ""
        }

        Task {
            let typingIndicator = Message(text: "...", isUser: false)
            DispatchQueue.main.async {
                self.messages.append(typingIndicator)
            }

            try? await Task.sleep(nanoseconds: 1_000_000_000)

            let response = await generateResponse(for: userMessage.text)
            DispatchQueue.main.async {
                if let index = self.messages.firstIndex(where: { $0.id == typingIndicator.id }) {
                    self.messages[index] = Message(text: response, isUser: false)
                }
            }
        }
    }

    func generateResponse(for query: String) async -> String {
        if query.lowercased().contains("status of my transaction") || query == "1" {
            return "Your transaction is currently pending."
        } else if query.lowercased().contains("best time to send money to the philippines") || query == "2" {
            return "The best time to send money is on Monday and Friday."
        } else {
            return "I'm here to assist you with transactions and fees."
        }
    }
}
