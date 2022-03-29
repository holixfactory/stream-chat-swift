//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
@testable import StreamChat
import XCTest

extension ChatClient {
    static var defaultMockedConfig: ChatClientConfig {
        var config = ChatClientConfig(apiKey: .init("--== Mock ChatClient ==--"))
        config.isLocalStorageEnabled = false
        config.isClientInActiveMode = false
        return config
    }

    /// Create a new instance of mock `ChatClient`
    static func mock(config: ChatClientConfig? = nil) -> ChatClient {
        .init(
            config: config ?? defaultMockedConfig,
            environment: .init(
                apiClientBuilder: APIClientSpy.init,
                webSocketClientBuilder: {
                    WebSocketClientMock(
                        sessionConfiguration: $0,
                        requestEncoder: $1,
                        eventDecoder: $2,
                        eventNotificationCenter: $3
                    )
                },
                databaseContainerBuilder: {
                    try DatabaseContainerSpy(
                        kind: $0,
                        shouldFlushOnStart: $1,
                        shouldResetEphemeralValuesOnStart: $2,
                        localCachingSettings: $3,
                        deletedMessagesVisibility: $4,
                        shouldShowShadowedMessages: $5
                    )
                }
            )
        )
    }
}

extension ChatClient {
    static var mock: ChatClient {
        ChatClientMock(
            config: .init(apiKey: .init(.unique)),
            workerBuilders: [],
            environment: .mock
        )
    }
    
    var mockAPIClient: APIClientSpy {
        apiClient as! APIClientSpy
    }
    
    var mockWebSocketClient: WebSocketClientMock {
        webSocketClient as! WebSocketClientMock
    }
    
    var mockDatabaseContainer: DatabaseContainerSpy {
        databaseContainer as! DatabaseContainerSpy
    }

    func simulateProvidedConnectionId(connectionId: ConnectionId?) {
        guard let connectionId = connectionId else {
            webSocketClient(
                mockWebSocketClient,
                didUpdateConnectionState: .disconnected(source: .serverInitiated(error: nil))
            )
            return
        }
        webSocketClient(mockWebSocketClient, didUpdateConnectionState: .connected(connectionId: connectionId))
    }
}

final class ChatClientMock: ChatClient {
    @Atomic var init_config: ChatClientConfig
    @Atomic var init_tokenProvider: TokenProvider?
    @Atomic var init_environment: Environment
    @Atomic var init_completion: ((Error?) -> Void)?

    @Atomic var fetchCurrentUserIdFromDatabase_called = false

    @Atomic var createBackgroundWorkers_called = false

    @Atomic var completeConnectionIdWaiters_called = false
    @Atomic var completeConnectionIdWaiters_connectionId: String?

    @Atomic var completeTokenWaiters_called = false
    @Atomic var completeTokenWaiters_token: Token?

    override var backgroundWorkers: [Worker] {
        _backgroundWorkers ?? super.backgroundWorkers
    }

    private var _backgroundWorkers: [Worker]?

    // MARK: - Overrides

    init(
        config: ChatClientConfig,
        tokenProvider: TokenProvider? = nil,
        workerBuilders: [WorkerBuilder] = [],
        environment: Environment = .mock
    ) {
        init_config = config
        init_tokenProvider = tokenProvider
        init_environment = environment

        super.init(
            config: config,
            tokenProvider: tokenProvider,
            environment: environment
        )
        if !workerBuilders.isEmpty {
            _backgroundWorkers = workerBuilders.map { $0(databaseContainer, apiClient) }
        }
    }

    override func fetchCurrentUserIdFromDatabase() -> UserId? {
        fetchCurrentUserIdFromDatabase_called = true
        
        return super.fetchCurrentUserIdFromDatabase()
    }

    override func createBackgroundWorkers() {
        createBackgroundWorkers_called = true

        super.createBackgroundWorkers()
    }

    override func completeConnectionIdWaiters(connectionId: String?) {
        completeConnectionIdWaiters_called = true
        completeConnectionIdWaiters_connectionId = connectionId

        super.completeConnectionIdWaiters(connectionId: connectionId)
    }

    override func completeTokenWaiters(token: Token?) {
        completeTokenWaiters_called = true
        completeTokenWaiters_token = token

        super.completeTokenWaiters(token: token)
    }

    // MARK: - Clean Up

    func cleanUp() {
        (apiClient as? APIClientSpy)?.cleanUp()

        fetchCurrentUserIdFromDatabase_called = false

        createBackgroundWorkers_called = false

        completeConnectionIdWaiters_called = false
        completeConnectionIdWaiters_connectionId = nil

        completeTokenWaiters_called = false
        completeTokenWaiters_token = nil
    }
}

extension ChatClient.Environment {
    static var mock: ChatClient.Environment {
        .init(
            apiClientBuilder: APIClientSpy.init,
            webSocketClientBuilder: {
                WebSocketClientMock(
                    sessionConfiguration: $0,
                    requestEncoder: $1,
                    eventDecoder: $2,
                    eventNotificationCenter: $3
                )
            },
            databaseContainerBuilder: {
                do {
                    return try DatabaseContainerSpy(
                        kind: .onDisk(databaseFileURL: .newTemporaryFileURL()),
                        shouldFlushOnStart: $1,
                        shouldResetEphemeralValuesOnStart: $2,
                        localCachingSettings: $3,
                        deletedMessagesVisibility: $4,
                        shouldShowShadowedMessages: $5
                    )
                } catch {
                    XCTFail("Unable to initialize DatabaseContainerSpy \(error)")
                    fatalError("Unable to initialize DatabaseContainerSpy \(error)")
                }
            },
            requestEncoderBuilder: DefaultRequestEncoder.init,
            requestDecoderBuilder: DefaultRequestDecoder.init,
            eventDecoderBuilder: EventDecoder.init,
            notificationCenterBuilder: EventNotificationCenter.init,
            clientUpdaterBuilder: ChatClientUpdaterMock.init
        )
    }

    static var withZeroEventBatchingPeriod: Self {
        .init(
            webSocketClientBuilder: {
                var webSocketEnvironment = WebSocketClient.Environment()
                webSocketEnvironment.eventBatcherBuilder = {
                    Batcher<Event>(period: 0, handler: $0)
                }
                
                return WebSocketClient(
                    sessionConfiguration: $0,
                    requestEncoder: $1,
                    eventDecoder: $2,
                    eventNotificationCenter: $3,
                    environment: webSocketEnvironment
                )
            }
        )
    }
}
