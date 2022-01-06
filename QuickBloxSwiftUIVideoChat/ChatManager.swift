//
//  ChatManager.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 28.09.2021.
//

import UIKit
import Quickblox

class ChatManager: NSObject {
    
    static let instance: ChatManager = {
        let instance = ChatManager()
        return instance
    }()
    
    func fetchUsers(currentPage: UInt, perPage: UInt, completion: @escaping (_ response: QBResponse?, _ objects: [QBUUser], _ cancel: Bool) -> Void) {
        let page = QBGeneralResponsePage(currentPage: currentPage, perPage: perPage)
        QBRequest.users(withExtendedRequest: ["order": "desc date last_request_at"],
                        page: page,
                        successBlock: { (response, page, users) in
                            let cancel = users.count < page.perPage
                            completion(nil, users, cancel)
        }, errorBlock: { response in
            completion(response, [], false)
            debugPrint("[ChatManager] searchUsers error: \(self.errorMessage(response: response) ?? "")")
        })
    }
    
    //Handle Error
    private func errorMessage(response: QBResponse) -> String? {
        var errorMessage : String
        if response.status.rawValue == 502 {
            errorMessage = "SA_STR_BAD_GATEWAY".localized
        } else if response.status.rawValue == 0 {
            errorMessage = "SA_STR_NETWORK_ERROR".localized
        } else {
            guard let qberror = response.error,
                  let error = qberror.error else {
                      return nil
                  }
            errorMessage = error.localizedDescription.replacingOccurrences(of: "(",
                                                                           with: "",
                                                                           options:.caseInsensitive,
                                                                           range: nil)
            errorMessage = errorMessage.replacingOccurrences(of: ")",
                                                             with: "",
                                                             options: .caseInsensitive,
                                                             range: nil)
        }
        return errorMessage
    }
}
