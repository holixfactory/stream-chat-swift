//
//  StreamChatWrapper.swift
//  StreamChatUITestsApp
//
//  Created by Boris Bielik on 09/03/2022.
//  Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamChat
import StreamChatUI
import UIKit

class StreamChatWrapper {

    var userCredentials: UserCredentials?

    func setupChatClient(with userCredentials: UserCredentials) {
        self.userCredentials = userCredentials
        let config = ChatClientConfig(apiKey: .init(apiKey))

        /// create an instance of ChatClient and share it using the singleton
        ChatClient.shared = ChatClient(config: config)

        /// connect to chat
        ChatClient.shared.connectUser(
            userInfo: UserInfo(
                id: userCredentials.id,
                name: userCredentials.name,
                imageURL: userCredentials.avatarURL
            ),
            token: userCredentials.token
        )
    }

    func makeChannelListViewController() -> UIViewController {
        // UI
        let channelList = ChannelListVC()
        let query = ChannelListQuery(filter: .containMembers(userIds: [userCredentials?.id ?? ""]))
        channelList.controller = ChatClient.shared.channelListController(query: query)

        return channelList
    }

}


// MARK: Logger
extension StreamChatWrapper {

    private func setupLogger() {
        LogConfig.formatters = []
        LogConfig.level = .error
    }
}
