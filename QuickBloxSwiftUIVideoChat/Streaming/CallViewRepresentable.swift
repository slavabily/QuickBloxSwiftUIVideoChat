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
    
    var opponent: QBUUser
    
    func makeUIViewController(context: Context) -> CallViewController {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let callVC = storyboard.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
        callVC.user = opponent
        
        return callVC
    }
    
    func updateUIViewController(_ callVC: CallViewController, context: Context) {
        
    }
}

