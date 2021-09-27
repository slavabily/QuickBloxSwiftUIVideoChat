//
//  CallViewController.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 20.09.2021.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class CallViewController: UIViewController {
    
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
        QBRTCClient.instance().add(self as QBRTCClientDelegate)
        
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
            QBRTCClient.initializeRTC()
        }
    }
}

// MARK: QBRTCClientDelegate

extension CallViewController: QBRTCClientDelegate {
    // MARK: QBRTCClientDelegate
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
    }
    
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
    }
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
    }
    
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
    }
    
    // MARK: QBRTCBaseClientDelegate
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState) {
    }
    
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteAudioTrack audioTrack: QBRTCAudioTrack, fromUser userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber) {
    }
    
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
    }
}

// MARK: QBChatDelegate
extension CallViewController: QBChatDelegate {
    func chatDidConnect() {
        print("The client connected to the chat.")
    }
    func chatDidReconnect() {
        print("The client reconnected to the chat.")
    }
    func chatDidDisconnectWithError(_ error: Error?) {
        print("The client disconnected from the chat \(String(describing: error)).")
    }
    func chatDidNotConnectWithError(_ error: Error) {
        print("The client did not connect to the chat \(error)")
    }
}
