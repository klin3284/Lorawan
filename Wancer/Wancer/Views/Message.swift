import SwiftUI
import SwiftData

struct ChatView: View {
  @EnvironmentObject var user: User // Inject the current user
  @StateObject var viewModel: ChatViewModel // View model for chat data
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Text(viewModel.contactName)
          .font(.title2)
          .bold()
        Spacer()
      }
      
      List(viewModel.messages) { message in
        BubbleView(message: message, user: user)
      }
      .listStyle(.plain)
      .frame(maxHeight: .infinity)
      
      HStack(spacing: 16) {
        TextField("Type your message", text: $viewModel.newMessageText)
        Button(action: {
          viewModel.sendMessage()
        }) {
          Image(systemName: "paperplane.fill")
            .foregroundColor(.blue)
        }
      }
    }
    .padding()
    .onAppear {
      viewModel.loadMessages()
    }
  }
}

struct BubbleView: View {
  let message: Message
  let user: User
  
  var body: some View {
    Text(message.text)
      .padding()
      .background(message.author.id == user.id ? Color.blue : Color.gray)
      .foregroundColor(message.author.id == user.id ? .white : .black)
      .cornerRadius(10)
      .fixedSize(horizontal: false, vertical: true)
      .frame(alignment: message.author.id == user.id ? .trailing : .leading)
  }
}

class ChatViewModel: ObservableObject {
  @Published var contactName: String = ""
  @Published var messages: [Message] = []
  @Published var newMessageText: String = ""
  
  let groupId: Int
  
  init(groupId: Int) {
    self.groupId = groupId
    fetchContactName()
  }
  
  func loadMessages() {
    // fetch messages for the group ID
  }
  
  func sendMessage() {
    // Create and save a new message
      
  }
  
  private func fetchContactName() {
    // fetch the contact name for the group

  }
}

