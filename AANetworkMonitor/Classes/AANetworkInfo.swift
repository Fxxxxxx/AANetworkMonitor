//
//  AANetworkInfo.swift
//  AANetworkMonitor
//
//  Created by Aaron on 2025/7/22.
//

import Foundation
import CoreTelephony

@available(iOS 12.0, *)
class AANetworkInfo {
    
    static let shared = AANetworkInfo()
    let ctNetworkInfo = CTTelephonyNetworkInfo()
    let observer: NSObjectProtocol?
    
    private init() {
        self.observer = NotificationCenter.default.addObserver(forName: .CTServiceRadioAccessTechnologyDidChange, object: nil, queue: nil) { _ in
            AANetworkMonitor.shared.queue.async {
                AANetworkMonitor.shared.update()
            }
        }
    }
    
    deinit {
        guard let observer = self.observer else { return }
        NotificationCenter.default.removeObserver(observer)
    }
    
    func getCellularDatail() -> AANetworkType {
        let radioAccess: String
        if #available(iOS 13.0, *) {
            guard let id = self.ctNetworkInfo.dataServiceIdentifier else { return .cellular }
            guard let ra = self.ctNetworkInfo.serviceCurrentRadioAccessTechnology?[id] else { return .cellular }
            radioAccess = ra
        } else {
            guard let ra = self.ctNetworkInfo.serviceCurrentRadioAccessTechnology?.first?.value else { return .cellular }
            radioAccess = ra
        }
        
        switch radioAccess {
        case CTRadioAccessTechnologyGPRS,
            CTRadioAccessTechnologyEdge,
        CTRadioAccessTechnologyCDMA1x:
            return .cellular2G
        case CTRadioAccessTechnologyWCDMA,
            CTRadioAccessTechnologyHSDPA,
            CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMAEVDORev0,
            CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB,
        CTRadioAccessTechnologyeHRPD:
            return .cellular3G
        case CTRadioAccessTechnologyLTE:
            return .cellular4G
        default:
            return.cellular4G
        }
    }
    
}
