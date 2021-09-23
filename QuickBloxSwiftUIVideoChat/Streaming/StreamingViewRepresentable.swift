//
//  StreamingViewRepresentable.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 20.09.2021.
//

import SwiftUI
import UIKit
import Quickblox

struct StreamingViewRepresentable: UIViewControllerRepresentable {
    
    @Binding var user: QBUUser
    
    func makeUIViewController(context: Context) -> StreamingViewController {
        let streamingViewController = StreamingViewController(user: user)
        
        return streamingViewController
    }
    
    func updateUIViewController(_ streamingViewController: StreamingViewController, context: Context) {
        
        streamingViewController.viewWillAppear(true)
    }
}

