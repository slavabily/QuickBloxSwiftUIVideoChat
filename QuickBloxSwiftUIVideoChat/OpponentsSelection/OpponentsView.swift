//
//  OpponentsView.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 26.09.2021.
//

import SwiftUI
import Quickblox

struct CreateNewDialogConstant {
    static let perPage:UInt = 100
    static let newChat = "New Chat"
    static let noUsers = "No user with that name"
}

struct OpponentsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var usersSelection = UsersSelection()
    @State private var users : [QBUUser] = []
    @State private var downloadedUsers : [QBUUser] = []
    @State private var currentFetchPage: UInt = 1
    @State private var cancelFetch = false
    @State private var searchBarText = ""
    @State private var cancelSearchButtonisShown = false
    private let chatManager = ChatManager.instance
    
    var users_: [QBUUser] {
        if searchBarText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.fullName?.contains(searchBarText) ?? true
            }
        }
     }
    
    var body: some View {
        List(users_, id: \.self) { user in
            NavigationLink(destination: CallViewRepresentable(opponent: user).navigationTitle("Chat with \(user.login ?? "Unknown")")) {
                UserCell(usersSelection: usersSelection, user: user)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: {
                                    disconnectUser()
                                }, label: {
                                    Image("exit")
                                }),
                            trailing: HStack(spacing: 30) {
                                Button {
                                    // TODO: navigation to info view
                                } label: {
                                    Image(systemName: "info.circle")
                                        .scaleEffect(1.5)
                                }
                            })
        .navigationBarTitle("Select opponent", displayMode: .inline)
        .onAppear {
            fetchUsers()
        }
    }
    
    private func fetchUsers() {
        chatManager.fetchUsers(currentPage: currentFetchPage, perPage: CreateNewDialogConstant.perPage) { response, users, cancel in
            self.cancelFetch = cancel
            if cancel == false {
                self.currentFetchPage += 1
            }
            self.downloadedUsers.append(contentsOf: users)
            self.setupUsers(self.downloadedUsers )
        }
    }
    
    private func setupUsers(_ users: [QBUUser]) {
        var filteredUsers: [QBUUser] = []
        let currentUser = Profile()
        if currentUser.isFull == true {
            filteredUsers = users.filter({$0.id != currentUser.ID})
        }
        self.users = filteredUsers
        if usersSelection.selectedUsers.isEmpty == false {
            var usersSet = Set(users)
            for user in usersSelection.selectedUsers {
                if usersSet.contains(user) == false {
                    self.users.insert(user, at: 0)
                    usersSet.insert(user)
                }
            }
        }
    }
    
    //MARK: - logOut flow
    private func disconnectUser() {
        QBChat.instance.disconnect(completionBlock: { error in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            self.logOut()
        })
    }
    
    private func logOut() {
        QBRequest.logOut(successBlock: { response in
            //ClearProfile
            Profile.clearProfile()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                presentationMode.wrappedValue.dismiss()
            }
        }, errorBlock: { response in
            debugPrint("[DialogsViewController] logOut error: \(response)")
        })
    }
}

struct OpponentsView_Previews: PreviewProvider {
    static var previews: some View {
        OpponentsView()
    }
}
