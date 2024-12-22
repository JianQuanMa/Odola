//
//  ChatView.swift
//  Odola
//
//  Created by Jian Ma on 12/17/24.
//
import SwiftUI
import Combine

// MARK: - Models
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

// Mock transaction data
struct Transaction: Codable {
    let id: String
    let status: String
    let bestRates: [String]?
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(text: "Welcome! I am a chatbot that assists you with any questions you have. You can type '1. status of my transaction' to check your transaction status or '2. best time to send money to the Philippines' to get the best rates. Or simply their digits.", isUser: false)
    ]
    @Published var query: String = ""

    private var transactions: [Transaction] = []
    private let jsonFileName = "Transactions.json"
    private let cacheKey = "CachedTransactions"

    init() {
        loadMockData()
    }

    func sendMessage() {
        guard !query.isEmpty else { return }

        let userMessage = Message(text: query, isUser: true)
        messages.append(userMessage)
        query = ""

        Task {
            let response = await generateResponse(for: userMessage.text)
            DispatchQueue.main.async {
                self.messages.append(Message(text: response, isUser: false))
            }
        }
    }

    private func generateResponse(for query: String) async -> String {
        // Introduce a delay of 0.5 seconds
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds delay

        if query.lowercased().contains("status of my transaction") || query == "1" {
            return transactions.first?.status ?? "Transaction data unavailable."
        } else if query.lowercased().contains("best time to send money to the philippines") || query == "2" {
            return transactions.first?.bestRates?.joined(separator: ", ") ?? "No data on best rates."
        } else {
            return "I'm here to assist you with transactions and fees. Type '1' for transaction status or '2' for the best time to send money."
        }
    }


    private func loadMockData() {
        // Attempt to load cached data first
        if let cachedData = UserDefaults.standard.data(forKey: cacheKey) {
            decodeTransactions(from: cachedData)
        } else {
            // Load from the JSON file if no cached data is found
            guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: nil) else {
                print("Mock data file not found.")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                decodeTransactions(from: data)
                // Cache the data for offline use
                UserDefaults.standard.set(data, forKey: cacheKey)
            } catch {
                print("Failed to load or decode mock data: \(error)")
            }
        }
    }

    private func decodeTransactions(from data: Data) {
        do {
            transactions = try JSONDecoder().decode([Transaction].self, from: data)
        } catch {
            print("Failed to decode transaction data: \(error)")
        }
    }
}
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var isChatVisible = false
    @State private var isRatingMode = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                if isChatVisible {
                    if isRatingMode {
                        // Rating Mode UI
                        VStack {
                            Text("Rate this Conversation")
                                .font(.title)
                                .padding()

                            HStack(spacing: 50) {
                                Button(action: {
                                    submitFeedback(isPositive: true) // Handle thumbs-up feedback
                                }) {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.green)
                                }

                                Button(action: {
                                    submitFeedback(isPositive: false) // Handle thumbs-down feedback
                                }) {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                    } else {
                        // Chat UI
                        VStack(spacing: 0) {
                            // Purple Top Bar
                            HStack {
                                Image("bot") // Replace with your bot image name
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .padding(.leading, 10)

                                Text("Chat Assistant")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Spacer()

                                // Top-right menu button
                                Menu {
                                    Button("Rate this conversation", action: {
                                        withAnimation {
                                            isRatingMode = true // Switch to rating mode
                                        }
                                    })
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .resizable()
                                        .frame(width: 20, height: 5)
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 10)
                            }
                            .padding()
                            .background(Color.purple)

                            // Chat Messages
                            ScrollViewReader { proxy in
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(viewModel.messages) { message in
                                            ChatBubble(message: message)
                                                .id(message.id)
                                        }
                                    }
                                }
                                .onChange(of: viewModel.messages.count) { _ in
                                    if let lastMessage = viewModel.messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }

                            // Chat Input Area
                            HStack {
                                TextField("Type a message...", text: $viewModel.query)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.leading, 10)

                                Button(action: {
                                    viewModel.sendMessage()
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(viewModel.query.isEmpty ? Color.gray : Color.blue)
                                        .clipShape(Circle())
                                }
                                .disabled(viewModel.query.isEmpty)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                        .frame(height: isChatVisible ? UIScreen.main.bounds.height * 0.75 : 0)
                        .animation(.easeInOut, value: isChatVisible)
                    }
                }
            }
            .animation(.easeInOut, value: isChatVisible)

            // Floating toggle button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isChatVisible.toggle()
                            isRatingMode = false // Exit rating mode if chat is toggled
                        }
                    }) {
                        Image(systemName: isChatVisible ? "xmark.circle.fill" : "message.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Circle().fill(Color.white))
                            .shadow(radius: 10)
                    }
                    .padding(.trailing, 20)
                }
            }
        }
    }

    private func submitFeedback(isPositive: Bool) {
        // Append feedback to chat history
        let feedbackMessage = isPositive ? "Thanks for the feedback 😊" : "Thanks for the feedback 😞"
        viewModel.messages.append(Message(text: feedbackMessage, isUser: false))
        isRatingMode = false // Exit rating mode
    }
}


struct ChatBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)
            } else {
                Image("bot")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(.trailing, 8)

                Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}




