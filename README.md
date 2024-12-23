Take-Home Test for: Chat Functionality for a Digital Banking App
This take-home test is involves designing and implementing a SwiftUI-based app featuring a chat
assistant. This demo app should demonstrate proficiency in integrating chat UI, handling
asynchronous operations, unit testing, and managing data efficiently. Please feel free to use any
coding tools, assistants for frameworks.
Overview
The app should contain a chat assistant that is capable of answering user queries related to
transactions and fees. The chat assistant does not need to connect to a real AI backend; mock
responses can be used. The guidelines below are intended to provide some direction.
Guidelines
The app should include the following features:
1. A Smart Chat Assistant
A chatbot-style interface where the user can:
• Input at the bottom of the screen and enter queries like:
o “What is the status of my transaction”
o “When is the best time to send money to the Philippines cheaply?”
• AI responses and user queries displayed in a scrolling chat view
• Add support for message retries if sending a query fails (mock scenario)
• Smooth animations for chat bubbles appearing and input field resizing
• View responses from the assistant (mock responses are fine).
• Persist chat history during the session
• The expected mock behaviors are:
o If the user asks for their status of a transaction, the assistant replies with the status
(e.g. pending, paid out, etc.) (mocked value is fine)
o If the user asks for when the best time to send a payment to the Philippines, the
assistant displays dates where the user can expect the best rates (mock data is fine).
• Offline support - cache transaction data locally using UserDefaults or Core Data.
2. Mock Data Handling
You can use mock JSON data to simulate the following (but not limited to):
• Transactions and their status
• Predicted fees
• Mock data should be stored in JSON files and loaded into the app asynchronously
using async/await
3. User Experience and Design
UI and design are important, please consider:
• Clean and modern UI
• Ensure a responsive design
• Use SwiftUI principles to create reusable, modular components.
4. Technical Requirements
Below are the technical requirements:
• The app should use SwiftUI for all UI components (where possible)
• Architecture – use an appropriate architecture
• Testing - please include unit tests for core functionalities
