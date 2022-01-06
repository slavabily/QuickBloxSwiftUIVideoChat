//
//  StreamingViewRepresentable.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 20.09.2021.
//

import SwiftUI
import UIKit
import Quickblox

struct CallViewRepresentable: UIViewControllerRepresentable {
    
    var user: QBUUser
    
    func makeUIViewController(context: Context) -> CallViewController {
        let streamingViewController = CallViewController(user: user)
        
        return streamingViewController
    }
    
    func updateUIViewController(_ streamingViewController: CallViewController, context: Context) {
        
        streamingViewController.viewWillAppear(true)
    }
}

