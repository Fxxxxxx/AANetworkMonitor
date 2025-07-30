# iOS网络类型识别，还在使用过时的Reachability？试试最新的NWPathMonitor！

## 背景
网络识别能力是APP开发过程中不可或缺的重要能力，早期iOS识别网络类型，主要是通过[Reachability](https://developer.apple.com/library/archive/samplecode/Reachability/Introduction/Intro.html)实现，但是System Configuration相关的API在iOS 17.4及之后版本被Apple官方标记废弃了，取而代之的是NWPathMonitor，本文主要介绍相关的用法，并提供相关的代码封装供直接使用。

## NWPathMonitor用法
NWPathMonitor来自Network Framework，使用方式如下：

```
import Network

/// 创建NWPathMonitor实例
let monitor = NWPathMonitor()
/// 设置path更新回调
monitor.pathUpdateHandler = { [weak self] newPath in
    /// 消费newPath可以获取当前网络状态
}
/// 创建回调队列，调用start启动网络监听
let queue = DispatchQueue(label: "com.queue.AANetworkMonitor")
monitor.start(queue: queue)

```
消费pathUpdateHandler回调的NWPath实例，可以获取当前的网络状态，代码如下：

```
func handle(path: NWPath?) {
    guard let path = path else { return }
    guard path.status == .satisfied else {
	/// 离线状态
    }
    if path.usesInterfaceType(.other) {
        /// 未知的网络连接
    }
    if path.usesInterfaceType(.wifi) {
        /// wifi
    }
    if path.usesInterfaceType(.loopback) {
        /// 回环网络
    }
    if path.usesInterfaceType(.wiredEthernet) {
        /// 以太网
    }
    if path.usesInterfaceType(.cellular) {
        /// 蜂窝网络
    }
}
```

蜂窝类型，我们可以用`CTTelephonyNetworkInfo`细化为具体的4G、5G等，代码如下：

```
let ctNetworkInfo = CTTelephonyNetworkInfo()
/// 根据dataServiceIdentifier获取对应的radioAccess
let radioAccess: String
if #available(iOS 13.0, *) {
    guard let id = ctNetworkInfo.dataServiceIdentifier else { return .cellular }
    guard let ra = ctNetworkInfo.serviceCurrentRadioAccessTechnology?[id] else { return .cellular }
    radioAccess = ra
} else {
    guard let ra = self.ctNetworkInfo.serviceCurrentRadioAccessTechnology?.first?.value else { return .cellular }
    radioAccess = ra
}

/// 5G
if #available(iOS 14.1, *) {
    if radioAccess == CTRadioAccessTechnologyNRNSA
        || radioAccess == CTRadioAccessTechnologyNR {
        return .cellular5G
    }
}

switch radioAccess {
case CTRadioAccessTechnologyGPRS,
    CTRadioAccessTechnologyEdge,
CTRadioAccessTechnologyCDMA1x:
	/// 2G
	break
case CTRadioAccessTechnologyWCDMA,
    CTRadioAccessTechnologyHSDPA,
    CTRadioAccessTechnologyHSUPA,
    CTRadioAccessTechnologyCDMAEVDORev0,
    CTRadioAccessTechnologyCDMAEVDORevA,
    CTRadioAccessTechnologyCDMAEVDORevB,
CTRadioAccessTechnologyeHRPD:
	/// 3G
	break
case CTRadioAccessTechnologyLTE:
	/// 4G
	break
default:
	break
}
```
以上就是基本用法，可以自行封装成自己的网络识别工具，替换当前的Reachability。如果想要快速接入，可以考虑使用下文我封装好的工具。

## AANetworkMonitor基于NWPathMonitor的网络类型识别工具
项目地址：[AANetworkMonitor](https://github.com/Fxxxxxx/AANetworkMonitor)

集成方式，直接通过Cocoapods：

```ruby
pod 'AANetworkMonitor'
```

在工程尽量早的时期，初始化工具：

```
import AANetworkMonitor
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
	AANetworkMonitor.setup()
	return true
}
```

获取网络类型，直接调用相关接口；工具内还封装了通知，会在网络类型变化后主动发出，按需监听:

```
/// 网络类型枚举
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
/// 获取当前实时的网络类型
let type = AANetworkMonitor.currentNetworkType()
 
///  监听网络类型更新通知
NotificationCenter.default.addObserver(forName: .AANetworkTypeDidChangedNotification, object: nil, queue: nil) { notification in
    guard let userinfo = notification.userInfo else { return }
    print("AANetwork did changed, newValue: \(userinfo["newValue"] ?? ""), oldValue: \(userinfo["oldValue"] ?? "")")
}
```

##写在最后
> 欢迎直接使用代码，欢迎留言沟通交流！如果您觉得当前代码对您有帮助，欢迎打赏鼓励👏🏻

![251753860041_.pic.jpg](https://upload-images.jianshu.io/upload_images/3569202-a4412bacd07ff616.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


## License

AANetworkMonitor is available under the MIT license. See the LICENSE file for more info.
