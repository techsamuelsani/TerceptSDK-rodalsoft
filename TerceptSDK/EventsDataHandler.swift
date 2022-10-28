// Copyright (c) 2021, Tercept (https://www.tercept.com/)
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// 
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import UIKit

class EventsDataHandler  {

    private let lock = DispatchSemaphore(value: 1)
    
    private var _eventsData: [String:Any]? = [:]
    private var eventsData: [String:Any]? {
        get {
            lock.wait()
            defer { lock.signal() }
            return _eventsData
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _eventsData = newValue
        }
    }
    
    
    private var _eventsConfig: Dictionary<String,Dictionary<String,Int>?>? = [:]
    private var eventsConfig: Dictionary<String,Dictionary<String,Int>?>?{
        get {
            lock.wait()
            defer { lock.signal() }
            return _eventsConfig
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _eventsConfig = newValue
        }
    }
    
    

    init(){
        eventsData = [String:Any]()
    }

    public func setEventsConfig(_ eventsConfig: Dictionary<String,Dictionary<String,Int>?>) -> Void{
        self.eventsConfig = eventsConfig
    }

    public func update(_ adunit: String?, _ event: String?, _ customParams: [String:Any]) -> Void{
        do{
            if shouldLog(adunit!, event ?? "") {
                var tmpAdunitEvents: [[String:Any]] = [[:]]
                if eventsData![adunit!] != nil {
                    
                    // 26 Mar 2021 : Runtime error : Could not cast value of type 'Swift.Array<Swift.Dictionary<Swift.String, Any>>' (0x10e6f0120) to 'Swift.String' (0x10e6b3fd8).
                    // if let eventsDataJSONObj = try JSONSerialization.jsonObject(with: (eventsData![adunit!] as! String).data(using: .utf8)! , options: .allowFragments) as? [[String:String]] {
                    //     tmpAdunitEvents = eventsDataJSONObj
                    // }
                    
                    if let eventsDataUnwrapped = eventsData![adunit!] {
                        let eventsDataStr = String(describing: eventsDataUnwrapped)
                        
                        //if TerceptOptimization.isDebugMode {
                        //print("T: eventsDataStr = " +  eventsDataStr )
                        //}
                        
                        //if let eventsDataJSONObj = try JSONSerialization.jsonObject(with: eventsDataStr.data(using: .utf8)! , options: .allowFragments) as? [[String:Any]] {
                        //    tmpAdunitEvents = eventsDataJSONObj
                        //}
                        
                        tmpAdunitEvents = eventsDataUnwrapped as? [[String:Any]] ?? [[:]]
                    }
                    
                    
                    
                }
                else {
                    tmpAdunitEvents = [[String:Any]]()
                }

                var tmpObj: [String:Any] = [String:Any]()

                tmpObj["id"] = getId(event!)
                //tmpObj["timestamp"] = String(Date().timeIntervalSince1970 * 1000).dropLast(5).description   // this creates inconsistant time stamp
                tmpObj["timestamp"] = String(Int(Date().timeIntervalSince1970 * 1000))
                tmpObj["params"] = customParams

                tmpAdunitEvents.append(tmpObj)

                if let adunit = adunit {
                    eventsData?[adunit] = tmpAdunitEvents
                }
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class EventsDataHandler and method update", e)
        }
    }

    public func getAndResetEventsData() -> [String:Any]{
        var eventsDataJSON = getData()
        eventsData = [String:Any]()
        return eventsDataJSON
    }
    
    public func getData() -> [String:Any]{
        var finalDataObject: [String:Any] = [String:Any]()
        do{
            var keys: Dictionary<String, Any>.Keys.Iterator = eventsData!.keys.makeIterator()

            var tracking: [[String:Any]] = [[String:Any]]()
            while let rcKeysNextElement = keys.next(){
                let key: String = String("\(rcKeysNextElement)")
                var tmpObj: [String:Any] = [String:Any]()
                tmpObj["adUnitId"] = key
                if let eventsDataJSONObj = eventsData?[key] as? [[String:Any]] {
                    tmpObj["events"] = eventsDataJSONObj
                }
                tracking.append(tmpObj)
            }
            finalDataObject["tracking"] = tracking
            finalDataObject["fixedParams"] = DeviceInfo.DEVICE_INFO
            finalDataObject["customParams"] = CustomParams.get()
            finalDataObject["errors"] = ErrorLogHandler.getDataAndReset()
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class EventsDataHandler and method getData", e)
        }
        return finalDataObject
    }

    public func shouldLog(_ adunit: String?, _ event: String?) -> Bool{
        var log: Bool = false
        do{

            var adunitEventsConfig: Dictionary<String?,Int> = Constants.defaultEventsConfig
            if eventsConfig != nil {
                if !(eventsConfig!.isEmpty) {
                    if eventsConfig!.contains(where: { key, value in key == String(adunit!)}) {
                        adunitEventsConfig = eventsConfig![adunit!]!!
                    }
                } else {
                    adunitEventsConfig = [:]
                }
            } else {
                throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
            }

            if adunitEventsConfig.contains(where: { key, value in key == String(event!)}) {
                if adunitEventsConfig[event!] == Constants.TRUE {
                    log = true
                }
            } else {
                throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class EventsDataHandler and method shouldLog", e)
        }
        return log
    }

    private func getId(_ event: String?) -> Int{
        var id: Int = Int(-1)
        do{
            if Constants.eventIDs.count >= 0 {
                if Constants.eventIDs.contains(where: { key, value in key == String(event!)}) {
                    id = Constants.eventIDs[event!]!
                }
            } else {
                throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class EventsDataHandler and method getId", e)
        }
        return id
    }
    
}
