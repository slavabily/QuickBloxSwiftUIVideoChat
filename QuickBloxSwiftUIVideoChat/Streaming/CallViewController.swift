//
//  CallViewController.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 20.09.2021.
//

import UIKit
import Foundation
import Quickblox
import QuickbloxWebRTC

class CallViewController: UIViewController {
    
    @IBOutlet weak var localVideoView: UIView! // your video view to render local camera video stream
    
    var videoCapture: QBRTCCameraCapture?
    var session: QBRTCSession?
    var user: QBUUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBChat.instance.addDelegate(self)
        QBRTCClient.instance().add(self as QBRTCClientDelegate)
        QBRTCClient.initializeRTC()
        
        let videoFormat = QBRTCVideoFormat()
        videoFormat.frameRate = 30
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        // QBRTCCameraCapture class used to capture frames using AVFoundation APIs
        self.videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
        
        // add video capture to session's local media stream
        self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
        
        self.videoCapture?.previewLayer.frame = self.localVideoView.bounds
        
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    print("Camera access is granted...")
                } else {
                    print("Camera access is NOT granted!")
                }
            }
        
        self.videoCapture?.startSession()
        
        self.localVideoView.layer.insertSublayer(self.videoCapture!.previewLayer, at: 0)
                
                // start call
        startCall(to: user!)
    }
    
    func startCall(to user: QBUUser) {
        QBChat.instance.connect(withUserID: user.id, password: LoginConstants.defaultPassword, completion: { error in
            if let error = error {
                if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                    debugPrint("Unauthorised access!")
                } else {
                    debugPrint(LoginConstants.checkInternet)
                }
            }
            let opponentsIDs = [user.id]
            let newSession = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs as [NSNumber], with: .video)
            newSession.startCall(nil)
            print("The Call session has been started...")
        })
    }
    
    func acceptACall() {
        // userInfo - the custom user information dictionary for the accept call. May be nil.
//        let userInfo = ["key":"value"] // optional
        self.session?.acceptCall(nil)
    }
    
    func rejectCall() {
        // userInfo - the custom user information dictionary for the reject call. May be nil.
//        let userInfo = ["key":"value"] // optional
        self.session?.rejectCall(nil)

        // and release session instance
        self.session = nil
    }
    
    func endACall() {
        // userInfo - the custom user information dictionary for the reject call. May be nil.
//        let userInfo = ["key":"value"] // optional
        self.session?.hangUp(nil)

        // and release session instance
        self.session = nil
    }
    
    
}

// MARK: QBRTCClientDelegate

extension CallViewController: QBRTCClientDelegate {
    // MARK: QBRTCClientDelegate
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            // we already have a video/audio call session, so we reject another one
            // userInfo - the custom user information dictionary for the call from caller. May be nil.
            let userInfo = ["key":"value"] // optional
            session.rejectCall(userInfo)
            return
        }
        // saving session instance here
        self.session = session
        print("The outside call session has been received...")
    }
    
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("The user didn't respond to call...")
    }
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("Rejected by user \(userID)")
    }
    
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("Accepted by user: \(userID)")
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("Hang up by user: \(userID)")
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
