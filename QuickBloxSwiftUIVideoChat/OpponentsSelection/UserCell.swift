//
//  UserCell.swift
//  QuickBloxSwiftUIChat
//
//  Created by slava bily on 24.07.2021.
//

import SwiftUI
import Quickblox

struct UserCell: View {
    @ObservedObject var usersSelection: UsersSelection
     
    var user: QBUUser
    
    var body: some View {
        ZStack {
            usersSelection.isSelected(user) ? Color.gray : Color.white
            Text(user.fullName ?? "")
                .padding()
        }
    }
}

struct UserCell_Previews: PreviewProvider {
    static var previews: some View {
        UserCell(usersSelection: UsersSelection(), user: QBUUser())
    }
}
