//
//  AuthView.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 08.09.2021.
//

import SwiftUI
import Quickblox

struct LoginConstants {
    static let defaultPassword = "quickblox"
    static let checkInternet = NSLocalizedString("No Internet Connection", comment: "")
}

enum ErrorDomain: UInt {
    case signUp
    case logIn
    case logOut
    case chat
}

struct AuthView: View {
    
    @State private var login = ""
    @State private var fullName = ""
    @State private var opponentsViewIsPresented = false
    @State private var user = QBUUser()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Form {
                    Section(header: Text("Login")) {
                        TextField("", text: $login)
                    }
                    Section(header: Text("Full name")) {
                        TextField("", text: $fullName)
                    }
                }
                NavigationLink(destination: OpponentsView(user: $user), isActive: $opponentsViewIsPresented) {
                    Button("Login") {
                        signUp(fullName: fullName, login: login)
                    }
                    .font(.headline)
                    .padding()
                    .padding([.leading, .trailing], 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(30)
                 }
                .padding(.bottom, 50)
            }
            .navigationBarTitle("Enter to chat", displayMode: .inline)
        }
    }
    
    private func signUp(fullName: String, login: String) {
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = LoginConstants.defaultPassword
        
        QBRequest.signUp(newUser) { response, user in
            self.login(fullName: fullName, login: login)
        } errorBlock: { response  in
            if response.status == QBResponseStatusCode.validationFailed {
                // The user with existent login was created earlier
                self.login(fullName: fullName, login: login)
                return
            }
            self.handleError(response.error?.error, domain: ErrorDomain.signUp)
        }
    }
    
    private func login(fullName: String, login: String, password: String = LoginConstants.defaultPassword) {
        
        QBRequest.logIn(withUserLogin: login, password: password, successBlock: { (response, loggedInUser) in
            loggedInUser.password = password
            
            Profile.synchronize(user)
            
            if user.fullName != fullName {
                self.updateFullName(fullName: fullName, login: login)
            } else {
                self.connectToChat(user: user)
            }
            
        }, errorBlock: { (response) in
            self.handleError(response.error?.error, domain: ErrorDomain.logIn)
            if response.status == QBResponseStatusCode.unAuthorized {
                // Clean profile
            } 
        })
    }
    
    private func updateFullName(fullName: String, login: String) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: { response, user in
             
            Profile.update(user)
            self.connectToChat(user: user)
            
            }, errorBlock: { response in
                self.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
    
    private func connectToChat(user: QBUUser) {
         
        if QBChat.instance.isConnected == true {
            //did Login action
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                opponentsViewIsPresented.toggle()
            }
        } else {
            QBChat.instance.connect(withUserID: user.id,
                                    password: LoginConstants.defaultPassword,
                                    completion: { error in
                                         
                                        if let error = error {
                                            if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                // Clean profile
                                                Profile.clearProfile()
                                            } else {
                                                debugPrint(LoginConstants.checkInternet)
                                                self.handleError(error, domain: ErrorDomain.logIn)
                                            }
                                        } else {
                                            //did Login action
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                                                opponentsViewIsPresented.toggle()
                                            }
                                        }
                                    })
        }
    }
    
    // MARK: - Handle errors
    private func handleError(_ error: Error?, domain: ErrorDomain) {
        guard let error = error else {
            return
        }
        var infoText = error.localizedDescription
        print(infoText)
        if error._code == NSURLErrorNotConnectedToInternet {
            infoText = LoginConstants.checkInternet
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
