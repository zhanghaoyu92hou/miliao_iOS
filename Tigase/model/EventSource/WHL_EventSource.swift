//
//  WHL_EventSource.swift
//  WaHu_Lite
//
//  Created by lyj on 2020/3/19.
//  Copyright © 2020. All rights reserved.
//

import UIKit

class WHL_EventSource: NSObject {
    
    private var onMessageCallback: ((_ id: String?, _ event: String?, _ data: String?) -> Void)?
    var eventSource : EventSource?
    
    @objc func creatEventSource(host : String, uid : String) {
        print("SSE创建")

        let serverURL = URL(string: host + "/messages/feed?device=youjob&token=" + uid)!
        eventSource = EventSource(url: serverURL, headers: ["Authorization": "Bearer basic-auth-token"])

        eventSource?.onOpen { [weak self] in
            
            print("开始连接")
        }

        eventSource?.onComplete { [weak self] statusCode, reconnect, error in
            print("SSE链接:statusCode:\(statusCode), reconnect:\(reconnect) error:\(error)")

            guard reconnect ?? false else { return }

            let retryTime = self?.eventSource?.retryTime ?? 3000
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(retryTime)) { [weak self] in
                self?.eventSource?.connect()
            }
        }
        //客户端收到服务器发来的数据，就会触发message事件，可以在onmessage属性的回调函数。
        eventSource?.onMessage { [weak self] id, event, data in
            print("1SSE链接:id : \(id) event:\(event) data:\(data)")
            self?.onMessageCallback?(id, event, data)
        }
        // 另一种写法
        eventSource?.addEventListener("user-connected") { [weak self] id, event, data in
            print("2SSE链接:id : \(id) event:\(event) data:\(data)")
        }
    }
    
    @objc func closeEventSource(host : String, token : String) {
        print("关闭连接");
        let serverURL = URL(string: host + "/messages/feed/off?device=youjob&token=" + token)!
        eventSource = EventSource(url: serverURL, headers: ["Authorization": "Bearer basic-auth-token"])
        
        eventSource?.onOpen { [weak self] in
            print("断开连接");
        }
        
        eventSource?.onComplete{[weak self] statusCode, reconnect, error in
            print("断开连接结果：\(reconnect)  reconnect:\(reconnect) error:\(error)");
        }
        
        //客户端收到服务器发来的数据，就会触发message事件，可以在onmessage属性的回调函数。
        eventSource?.onMessage { [weak self] id, event, data in
//            print("1SSE链接:id : \(id) event:\(event) data:\(data)")
            self?.onMessageCallback?(id, event, data)
        }
        // 另一种写法
        eventSource?.addEventListener("user-connected") { [weak self] id, event, data in
//            print("2SSE链接:id : \(id) event:\(event) data:\(data)")
        }
    }
    
    @objc public func onMessage(_ onMessageCallback: @escaping ((_ id: String?, _ event: String?, _ data: String?) -> Void)) {
        self.onMessageCallback = onMessageCallback
    }
    
    @objc func disconnect(_ sender: Any) {
        eventSource?.disconnect()
    }
    
    @objc func connect(_ sender: Any) {
        eventSource?.connect()
    }
}
