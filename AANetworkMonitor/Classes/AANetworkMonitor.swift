//
//  AANetworkMonitor.swift
//  AANetworkMonitor
//
//  Created by Aaron Feng on 2025/7/21.
//

import Foundation
import Network
import CoreTelephony

public enum AANetworkType: String {
    case unknown = "unknown"
    case offline = "offline"
    case wifi = "wifi"
    case loopback = "loopback"
    case wiredEthernet = "wiredEthernet"
    case cellular = "cellular"
    case cellular2G = "cellular2G"
    case cellular3G = "cellular3G"
    case cellular4G = "cellular4G"
    case cellular5G = "cellular5G"
}

@available(iOS 12.0, *)
@objcMembers
public final class AANetworkMonitor: NSObject {
    
    static let shared = AANetworkMonitor()
    let queue = DispatchQueue(label: "com.queue.AANetworkMonitor")
    
    private let monitor = NWPathMonitor()
    private var networkType: AANetworkType = .unknown
    private var path: NWPath?
    
    private override init() {
        super.init()
        self.monitor.pathUpdateHandler = { [weak self] newPath in
            self?.path = newPath
            self?.update()
        }
        self.monitor.start(queue: self.queue)
        self.path = self.monitor.currentPath
    }
    
    func update() {
        guard let path = self.path else { return }
        guard path.status == .satisfied else {
            self.networkType = .offline
            return
        }
        if path.usesInterfaceType(.other) {
            self.networkType = .unknown
            return
        }
        if path.usesInterfaceType(.wifi) {
            self.networkType = .wifi
            return
        }
        if path.usesInterfaceType(.loopback) {
            self.networkType = .loopback
            return
        }
        if path.usesInterfaceType(.wiredEthernet) {
            self.networkType = .wiredEthernet
            return
        }
        if path.usesInterfaceType(.cellular) {
            self.networkType = AANetworkInfo.shared.getCellularDatail()
            return
        }
        self.networkType = .unknown
    }
    
}

@available(iOS 12.0, *)
public extension AANetworkMonitor {
    
    /// 当前网络类型
    static func currentNetworkType() -> AANetworkType {
        var type: AANetworkType = .unknown
        self.shared.queue.sync {
            type = self.shared.networkType
        }
        return type
    }
    
    /// 网络是否可用
    static func isAvaliable() -> Bool {
        return currentNetworkType() != .offline
    }
    
}
