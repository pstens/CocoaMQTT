//
// Created by Patrick Stens on 10.07.22.
//

import Foundation
#if IS_SWIFT_PACKAGE
import CocoaMQTT
#endif

public class CocoaMQTTHelper: NSObject {

    private var client: CocoaMQTT5?

    @objc public init(_ host: String, port: UInt16, deviceId: String, uri: String) {
        super.init()
        let websocket = CocoaMQTTWebSocket(uri: uri)
        client = CocoaMQTT5(clientID: deviceId, host: host, port: port, socket: websocket)
    }

    @objc public convenience init(_ host: String, port: UInt16, deviceId: String) {
        self.init(host, port: port, deviceId: deviceId, uri: "/mqtt")
    }

    @objc public func enableSSL(_ enabled: Bool) -> CocoaMQTTHelper {
        client?.enableSSL = enabled
        return self
    }

    @objc public func logLevel(_ level: CocoaMQTTLoggerLevel) -> CocoaMQTTHelper {
        client?.logLevel = level
        return self
    }

    @objc public func authentication(_ username: String, password: String) -> CocoaMQTTHelper {
        client?.username = username
        client?.password = password
        return self
    }

    @objc public func autoReconnect(_ enabled: Bool) -> CocoaMQTTHelper {
        client?.autoReconnect = enabled
        return self
    }

    @objc public func connect(_ onConnected: @escaping (CocoaMQTTCONNACKReasonCode) -> Void) {
        client?.didConnectAck = { _, reason, _ in
            onConnected(reason)
        }
        let _ = client?.connect()
    }

    @objc public func disconnect(_ onDisconnected: @escaping (CocoaMQTTDISCONNECTReasonCode) -> Void) {
        client?.didDisconnectReasonCode = { _, reason in
            onDisconnected(reason)
        }
        client?.disconnect()
    }

    @objc public func publish(_ topic: String, message: String, onPublished: @escaping () -> Void) {
        client?.didPublishMessage = { _, _, _ in
            onPublished()
        }
        client?.publish(topic, withString: message, properties: MqttPublishProperties())
    }
}
