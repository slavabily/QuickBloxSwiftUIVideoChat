//
//  CallViewController.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 20.09.2021.
//

import Foundation
import Quickblox
import QuickbloxWebRTC

class CallViewController: UIViewController {
    
    var localVideoView: UIView! // your video view to render local camera video stream
    var opponentVideoView: QBRTCRemoteVideoView! // your opponent's video view to render remote video stream
    var callButton: UIButton!
    
    var videoCapture: QBRTCCameraCapture?
    var session: QBRTCSession?
    var user: QBUUser
    
    init(localVideoView: UIView, opponentVideoView: QBRTCRemoteVideoView, callButton: UIButton, user: QBUUser) {
        self.localVideoView = localVideoView
        self.opponentVideoView = opponentVideoView
        self.callButton = callButton
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func call(_ sender: UIButton) {
        // start call
        startCall(to: user)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBChat.instance.addDelegate(self)
        QBRTCClient.instance().add(self as QBRTCClientDelegate)
        QBRTCClient.initializeRTC()
        
        // View's initialization
        
        opponentVideoView = QBRTCRemoteVideoView()
        view.addSubview(opponentVideoView)
        
        localVideoView = UIView()
        localVideoView.backgroundColor = .cyan
        opponentVideoView.addSubview(localVideoView)
        
        callButton = UIButton()
        callButton.setTitle("Call", for: .normal)
        callButton.setTitleColor(UIColor.white, for: .normal)
        callButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        opponentVideoView.addSubview(callButton)
        
        opponentVideoView.translatesAutoresizingMaskIntoConstraints = false
        opponentVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        opponentVideoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        opponentVideoView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        opponentVideoView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        localVideoView.translatesAutoresizingMaskIntoConstraints = false
        localVideoView.bottomAnchor.constraint(equalTo: opponentVideoView.bottomAnchor).isActive = true
        localVideoView.trailingAnchor.constraint(equalTo: opponentVideoView.trailingAnchor).isActive = true
        localVideoView.widthAnchor.constraint(equalTo: opponentVideoView.widthAnchor, multiplier: 0.4).isActive = true
        localVideoView.heightAnchor.constraint(equalTo: opponentVideoView.heightAnchor, multiplier: 0.3).isActive = true
        
        callButton.translatesAutoresizingMaskIntoConstraints = false
        callButton.leadingAnchor.constraint(equalTo: opponentVideoView.leadingAnchor).isActive = true
        callButton.bottomAnchor.constraint(equalTo: opponentVideoView.bottomAnchor).isActive = true
        callButton.widthAnchor.constraint(equalTo: opponentVideoView.widthAnchor, multiplier: 0.4).isActive = true
        callButton.heightAnchor.constraint(equalTo: opponentVideoView.heightAnchor, multiplier: 0.2).isActive = true
        
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
    }
    
    func startCall(to user: QBUUser) {
        callButton.isHidden = true
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
            print("The Call session with opponent \(opponentsIDs) has been started...")
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
        // accept call
        acceptACall()
    }
    
    func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("The user didn't respond to call...")
    }
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("Rejected by user...: \(userID)")
    }
    
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("Accepted by user...: \(userID)")
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("Hang up by user...: \(userID)")
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
        print("Receiving video track from opponent \(userID)...")
        // we suppose you have created UIView and set it's class to RemoteVideoView class
        // also we suggest you to set view mode to UIViewContentModeScaleAspectFit or
        // UIViewContentModeScaleAspectFill
        
        let remoteVideoTrack = self.session?.remoteVideoTrack(withUserID: userID) // video track for remote user
        
        self.opponentVideoView.setVideoTrack(remoteVideoTrack!)
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
