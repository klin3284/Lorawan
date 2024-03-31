import SwiftUI
import SwiftData

struct ChatView: View {
    @Environment(\.modelContext) var modelContext
    @State var user: User
    @State var viewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                ZStack(alignment: .leading) {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Text("\(user.firstName.prefix(1).uppercased())\(user.lastName.prefix(1).uppercased())")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .contentShape(Circle())
                        .offset(x: 16)
                }
                
                Text("\(user.firstName) \(user.lastName)")
                    .font(.title2)
                    .bold()
                Spacer()
            }

            Spacer()

            List {
                ForEach(viewModel.messages) { message in
                    HStack {
                        Spacer()
                        BubbleView(message: message, user: user)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                }
              }
              .listStyle(PlainListStyle())
              .frame(maxHeight: .infinity)
            
            HStack(spacing: 16) {
                TextField("Type your message", text: $viewModel.newMessageText )
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                
                Button(action: {
                    viewModel.sendMessage(user: user)
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 26))
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.messages = viewModel.loadMessages()
        }
    }
//    init(modelContext: ModelContext) {
//        let viewModel = ChatViewModel(modelContext: modelContext)
//        _viewModel = State(initialValue: viewModel)
//    }

}

struct BubbleView: View {
  let message: Message
  let user: User
  
  var body: some View {
      Text(message.text)
          .padding()
          .background(message.author == user ? Color.blue : Color.gray.opacity(0.4))
          .foregroundColor(message.author == user ? .white : .black)
          .cornerRadius(10)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: message.author == user ? .trailing : .leading)
  }
}
extension ChatView {
    @Observable
    class ChatViewModel: ObservableObject {
        var messages: [Message] = []
        var newMessageText: String = ""
        var modelContext: ModelContext
        private var groups = [Group]()
        private var currentGroup: Group?
        private var users = [User]()
        
        func fetchGroup() {
            do {
                groups = try modelContext.fetch(FetchDescriptor<Group>())
            }
            catch {
                print("fetch failed")
            }
        }
        func fetchUser() {
            do {
                users = try modelContext.fetch(FetchDescriptor<User>())
            }
            catch {
                print("fetch failed")
            }
        }
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            fetchUser()
            fetchGroup()
        }
        
        func loadMessages() -> [Message] {
            if let currentGroup {
                return currentGroup.messages.sorted(by: { $0.createdAt < $1.createdAt })
            }
            return []
        }
        
        func sendMessage(user: User) {
            if !newMessageText.isEmpty {
                    let msg = Message(id: messages.count + 1, text: newMessageText, createdAt: Date.now, author: user, seen: false, group: currentGroup!)
                    messages.append(msg)
                    newMessageText = ""
                }
            }
        }
}

    
//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//
//    let container = try! ModelContainer(for: Message.self, User.self, Group.self, configurations: config)
//    let user = User(id: 104, firstName: "Ethan", lastName: "Liu", groups: [])
//    let user1 = User(id: 103, firstName: "John", lastName: "Smith", groups: [])
//
//    let group = Group(id: 204, name: "group", users: [user], messages: [])
//        
//    container.mainContext.insert(user)
//    container.mainContext.insert(group)
//        
//    user.groups.append(group)
//
//    let message1 = Message(id: 300, text: "Helloooo!", createdAt: Date.now, author: user1, seen: false, group: group)
//    let message2 = Message(id: 400, text: "Hi!", createdAt: Date.now.addingTimeInterval(1000), author: user1, seen: true, group: group)
//    group.addMessage(message1)
//    group.addMessage(message2)
//    
//    return ChatView(user: user, viewModel: ChatViewModel(groupId: group.id, groups: [group], users: [user]))
//        .modelContainer(container)
//}
//
