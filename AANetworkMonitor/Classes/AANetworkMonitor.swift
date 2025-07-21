//
//  AANetworkMonitor.swift
//  AANetworkMonitor
//
//  Created by Aaron Feng on 2025/7/21.
//

import Foundation
import Network

public enum AANetworkType: String {
    case unknown = "unknown"
    case offline = "offline"
    case wifi = "wifi"
    case loopback = "loopback"
    case wiredEthernet = "wiredEthernet"
    case cellular2G = "cellular2G"
    case cellular3G = "cellular3G"
    case cellular4G = "cellular4G"
    case cellular5G = "cellular5G"
}

@available(iOS 12.0, *)
@objcMembers
public final class AANetworkMonitor: NSObject {
    
    public let shared = AANetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private var networkType: AANetworkType = .unknown
    private let queue = DispatchQueue(label: "com.queue.AANetworkMonitor")
    private let specifedKey = DispatchSpecificKey<AANetworkMonitor>()
    
    private override init() {
        super.init()
        queue.setSpecific(key: self.specifedKey, value: self)
        
        self.monitor.pathUpdateHandler = { [weak self] newPath in
            self?.handle(path: newPath)
        }
        self.monitor.start(queue: self.queue)
    }
    
    private func runInQueue(_ block: @escaping () -> Void) {
        guard let speccifed = DispatchQueue.getSpecific(key: self.specifedKey), speccifed == self else {
            block()
            return
        }
        self.queue.async(execute: block)
    }
    
    private func handle(path: NWPath) {
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
        /// todo: cellular
        if path.usesInterfaceType(.cellular) {
            return
        }
        self.networkType = .unknown
    }
    
}
