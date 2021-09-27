//
//  UserDataSource.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 26.09.2021.
//

import UIKit
import Quickblox

class UsersDataSource: NSObject, ObservableObject {
    
    // MARK: - Properties
    var selectedUsers = [QBUUser]()
    private var users = [QBUUser]()
}
