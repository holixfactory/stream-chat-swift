//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

@testable import StreamChat
@testable import StreamChatTestTools
@testable import StreamChatUI
import SwiftUI
import XCTest

@available(iOS 13.0, *)
final class ChatThreadView_Tests: iOS13TestCase {
    var chatThreadView: SwiftUIViewControllerRepresentable<ChatThreadVC>!
    
    var channelControllerMock: ChatChannelControllerMock!
    var messageControllerMock: ChatMessageControllerMock!

    override func setUp() {
        super.setUp()
        channelControllerMock = ChatChannelControllerMock.mock()
        messageControllerMock = ChatMessageControllerMock.mock()
        channelControllerMock.simulateInitial(
            channel: .mock(cid: .unique),
            messages: [],
            state: .remoteDataFetched
        )
        messageControllerMock.simulateInitial(
            message: .mock(id: .unique, cid: .unique, text: "First message", author: .mock(id: .unique)),
            replies: [
                .mock(
                    id: .unique,
                    cid: .unique,
                    text: "First reply",
                    author: .mock(id: .unique, name: "Author author")
                ),
                .mock(id: .unique, cid: .unique, text: "Second reply", author: .mock(id: .unique)),
                .mock(id: .unique, cid: .unique, text: "Third reply", author: .mock(id: .unique))
            ],
            state: .localDataFetched
        )
        chatThreadView = ChatThreadVC.asView(
            (
                channelController: channelControllerMock,
                messageController: messageControllerMock
            )
        )
    }

    func test_chatThreadVC_isPopulated() {
        AssertSnapshot(
            chatThreadView,
            isEmbeddedInNavigationController: true,
            variants: [.defaultLight]
        )
    }

    func test_customNavigationViewValues_arePopulated() {
        struct CustomView: View {
            let channelControllerMock = ChatChannelControllerMock.mock()
            let messageControllerMock = ChatMessageControllerMock.mock()

            init() {
                channelControllerMock.simulateInitial(
                    channel: .mock(cid: .unique),
                    messages: [],
                    state: .localDataFetched
                )
                messageControllerMock.simulateInitial(
                    message: .mock(id: .unique, cid: .unique, text: "First message", author: .mock(id: .unique)),
                    replies: [
                        .mock(id: .unique, cid: .unique, text: "First reply", author: .mock(id: .unique)),
                        .mock(id: .unique, cid: .unique, text: "Second reply", author: .mock(id: .unique)),
                        .mock(id: .unique, cid: .unique, text: "Third reply", author: .mock(id: .unique))
                    ],
                    state: .localDataFetched
                )
            }
            
            var body: some View {
                NavigationView {
                    ChatThreadVC.asView(
                        (
                            channelController: channelControllerMock,
                            messageController: messageControllerMock
                        )
                    )
                    .navigationBarTitle("Custom title", displayMode: .inline)
                    .navigationBarItems(
                        leading:
                        Button("Tap me!") {}
                    )
                }
            }
        }

        let customView = CustomView()
        AssertSnapshot(customView)
    }
}
