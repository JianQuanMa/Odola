//
//  ChatViewModelTests.swift
//  OdolaTests
//
//  Created by Jian Ma on 12/22/24.
//

import XCTest
@testable import Odola

final class ChatViewModelTests: XCTestCase {
    var viewModel: ChatViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ChatViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Test: Send Message

    func test_sendMessage_success() async {
        // Given
        viewModel.query = "1" // Valid query for transaction status
        let initialCount = viewModel.messages.count
        
        // When
        viewModel.sendMessage()
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        // Then
        XCTAssertEqual(viewModel.messages.count, initialCount + 2, "The user message and the answer should be appended.")
        XCTAssertEqual(viewModel.messages.last?.text, "Your transaction is currently pending.", "The last message should be the answer to the user's query.")
    }

    func test_sendMessage_fail() {
        // Given
        viewModel.query = "" // Invalid empty query
        let initialCount = viewModel.messages.count
        
        // When
        viewModel.sendMessage()
        
        // Then
        XCTAssertEqual(viewModel.messages.count, initialCount, "No messages should be added for an empty query.")
    }
    
    // MARK: - Test: Generate Response

    func test_generateResponse_success() async {
        // Given
        let query = "1" // Valid query for transaction status
        
        // When
        let response = await viewModel.generateResponse(for: query)
        
        // Then
        XCTAssertEqual(response, "Your transaction is currently pending.", "The response should match the expected transaction status.")
    }

    func test_generateResponse_fail() async {
        // Given
        let query = "invalid query" // Invalid query
        
        // When
        let response = await viewModel.generateResponse(for: query)
        
        // Then
        XCTAssertEqual(response, "I'm here to assist you with transactions and fees.")
    }
}

