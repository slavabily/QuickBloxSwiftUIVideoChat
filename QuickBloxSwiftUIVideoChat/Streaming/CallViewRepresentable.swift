//
//  CallViewRepresentable.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 20.09.2021.
//

import SwiftUI
import UIKit
import Quickblox
import QuickbloxWebRTC

struct CallViewRepresentable: UIViewControllerRepresentable {
    
    var opponent: QBUUser
    
    func makeUIViewController(context: Context) -> CallViewController {
        let callVC = CallViewController(localVideoView: UIView(),
                                        opponentVideoView: QBRTCRemoteVideoView(),
                                        callButton: UIButton(),
                                        user: opponent)

        return callVC
    }
    
    func updateUIViewController(_ callVC: CallViewController, context: Context) {
        
    }
}

