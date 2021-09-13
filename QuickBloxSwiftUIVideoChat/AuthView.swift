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
//    @State private var password = ""
    
    @State private var nextViewIsPresented = false
    
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
//                    Section(header: Text("Password")) {
//                        TextField("", text: $password)
//                    }
                }
                NavigationLink(destination: Circle(), isActive: $nextViewIsPresented) {
                    Button("Login") {
                        signUp(login: login, fullName: fullName)
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
    
    private func signUp(login: String, fullName: String) {
        let user = QBUUser()
        user.login = login
        user.fullName = fullName
        user.password = LoginConstants.defaultPassword

        QBRequest.signUp(user, successBlock: { response, user in
            self.login(login: login)
        }, errorBlock: { (response) in
            if response.status == QBResponseStatusCode.validationFailed {
                // The user with existent login was created earlier
                self.login(login: login)
                return
            }
            self.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
    
    private func login(login: String, password: String = LoginConstants.defaultPassword) {
        
        QBRequest.logIn(withUserLogin: login, password: password, successBlock: { (response, user) in
            user.password = password
            connectToChat(user: user)
        }, errorBlock: { (response) in
            self.handleError(response.error?.error, domain: ErrorDomain.logIn)
            if response.status == QBResponseStatusCode.unAuthorized {
                // Clean profile
            } 
        })
    }
    
    private func connectToChat(user: QBUUser) {
        if QBChat.instance.isConnected == true {
            //did Login action
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                nextViewIsPresented.toggle()
            }
        } else {
            QBChat.instance.connect(withUserID: user.id, password: LoginConstants.defaultPassword) { error in
                if let error = error {
                    if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                        // Clean user profile
                        debugPrint("Unauthorised access!")
                    } else {
                        debugPrint(LoginConstants.checkInternet)
                        handleError(error, domain: ErrorDomain.logIn)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                        nextViewIsPresented.toggle()
                    }
                }
            }
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
