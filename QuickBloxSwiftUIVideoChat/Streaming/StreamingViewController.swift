//
//  StreamingViewController.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 20.09.2021.
//

import UIKit
import Quickblox

class StreamingViewController: UIViewController {
    
    var user: QBUUser
    
    init(user: QBUUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBChat.instance.addDelegate(self)
        
        connectToChat(user: user)
    }
    
    func connectToChat(user: QBUUser) {
        QBChat.instance.connect(withUserID: user.id, password: LoginConstants.defaultPassword) {error in
            if let error = error {
                if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                    debugPrint("Unauthorised access!")
                } else {
                    debugPrint(LoginConstants.checkInternet)
                }
            }
        }
    }
}

// MARK: QBChatDelegate
extension StreamingViewController: QBChatDelegate {
    func chatDidConnect() {
    }
    func chatDidReconnect() {
    }
    func chatDidDisconnectWithError(_ error: Error?) {
    }
    func chatDidNotConnectWithError(_ error: Error) {
    }
}
