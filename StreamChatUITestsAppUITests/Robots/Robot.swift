//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import XCTest

// MARK: Robot
protocol Robot: AnyObject { }

/// Declares the state of the switch (UI element)
///
/// - Returns: Self
enum SwitchState {
    case on
    case off
}

/// Declares the state of the UI element
///
/// - Returns: String
enum ElementState {
    case enabled(isEnabled: Bool)
    case visible(isVisible: Bool)
    case focused(isFocused: Bool)

    var errorMessage: String {
        let state: String
        switch self {
        case let .enabled(isEnabled):
            state = isEnabled ? "enabled" : "disabled"
        case let .focused(isFocused):
            state = isFocused ? "in focus" : "out of focus"
        case let .visible(isVisible):
            state = isVisible ? "visible" : "hidden"
        }
        return "Element should be \(state)"
    }
}

extension Robot {
    
    /// Closes the keyboard on the device
    ///
    /// - Returns: Self
    @discardableResult
    func dismissKeyboard() -> Self {
        app.swipeDown()
        return self
    }
    
    /// Waits for a new message from the user or participant
    ///
    /// - Returns: Self
    @discardableResult
    func waitForNewMessage(withText text: String) -> Self {
        let cell = MessageListPage.cells.firstMatch
        let textView = MessageListPage.Attributes.text(messageCell: cell)
        _ = textView.waitForText(text)
        return self
    }
    
    /// Waits for a new reaction from the user or participant
    ///
    /// - Returns: Self
    @discardableResult
    func waitForNewReaction() -> Self {
        let cell = MessageListPage.cells.firstMatch
        let reaction = MessageListPage.Attributes.reactionButton(messageCell: cell)
        reaction.wait()
        return self
    }
}
