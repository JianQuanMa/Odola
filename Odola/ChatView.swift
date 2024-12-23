//
//  ChatView.swift
//  Odola
//
//  Created by Jian Ma on 12/17/24.
//
import SwiftUI
import Combine

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var isChatVisible = true
    @State private var isRatingMode = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Image("bot")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.leading, 10)

                    Text("Chat Assistant")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Menu {
                        Button("Rate this conversation", action: {
                            withAnimation {
                                isRatingMode = true
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
                .frame(height: 100)
                .edgesIgnoringSafeArea(.top)

                if isChatVisible {
                    if isRatingMode {
                        VStack {
                            Text("Rate this Conversation")
                                .font(.title)
                                .padding()

                            HStack(spacing: 50) {
                                Button(action: {
                                    submitFeedback(isPositive: true)
                                }) {
                                    Image(systemName: "hand.thumbsup.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.green)
                                }

                                Button(action: {
                                    submitFeedback(isPositive: false)
                                }) {
                                    Image(systemName: "hand.thumbsdown.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                        }
                        .frame(height: isChatVisible ? UIScreen.main.bounds.height * 0.7 : 200)
                        .background(Color.white)
                    } else {
                        VStack(spacing: 0) {
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
                        .frame(height: isChatVisible ? UIScreen.main.bounds.height * 0.7 : 200)
                        .animation(.easeInOut, value: isChatVisible)
                    }
                }
            }
            .animation(.easeInOut, value: isChatVisible)
        }
    }

    private func submitFeedback(isPositive: Bool) {
        let feedbackMessage = isPositive ? "Thanks for the feedback 😊" : "Thanks for the feedback 😞"
        viewModel.messages.append(Message(text: feedbackMessage, isUser: false))
        isRatingMode = false
    }
}

struct ChatBubble: View {
    let message: Message
    @State private var isExpanded = false

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
                    .transition(.opacity)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded = true
                        }
                    }
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
                    .scaleEffect(isExpanded ? 1 : 0.8, anchor: .leading)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded = true
                        }
                    }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}
