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

class ResponseHandler  {

    private let lock = DispatchSemaphore(value: 1)
    
    private var _cache: CacheManager?
    private var cache: CacheManager?{
        get {
            lock.wait()
            defer { lock.signal() }
            return _cache
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _cache = newValue
        }
    }
    
    
    public var _adunitsConfig: [String:Any?]? = [:]
    public var adunitsConfig: [String:Any?]? {
        get {
            lock.wait()
            defer { lock.signal() }
            return _adunitsConfig
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _adunitsConfig = newValue
        }
    }
    
	
    init(_ cache: CacheManager, _ networkCode: String){
        self.cache = cache
        adunitsConfig = [String:Any]()
        update(nil, networkCode)
    }

    public func update(_ data: String?, _ networkCode: String) -> Void{
        do{
            var response: [[String:Any]] = [[String:Any]]()
            if data != nil {
                response = try JSONSerialization.jsonObject(with: Data(data!.utf8), options: .mutableContainers) as? [[String:Any]] ?? [[:]]
            }

            let adunitsConfigAsString: String? = cache!.read(Constants.ADUNITS_CONFIG_CACHE_KEY_NAME + "_" + networkCode)!
            if adunitsConfigAsString != nil {
                if !(adunitsConfigAsString!.isEmpty) {
                    
//                    if TerceptOptimization.isDebugMode {
//                    print("Tercept: adunitsConfigAsString = " + adunitsConfigAsString!.replacingOccurrences(of: "\\", with: ""))
//                    }
                    
                    adunitsConfig = try JSONSerialization.jsonObject(with: adunitsConfigAsString!.data(using: .utf8)!, options: .mutableContainers) as? [String:Any]
                }
            }

            var tmpObj: [String:Any] = [:]
            for i in sequence( first: 0, next: { i in i + 1}).prefix( while: { i in i < response.count }) {
                var tmpAdunitConfig: [String:Any] = [String:Any]()
                tmpObj = response[i]
                tmpAdunitConfig[Constants.TARGETING] = String(data: try JSONSerialization.data(withJSONObject: tmpObj[Constants.TARGETING], options: .fragmentsAllowed), encoding: .utf8)
                
                tmpAdunitConfig[Constants.EVENTS] = String(data: try JSONSerialization.data(withJSONObject: tmpObj[Constants.EVENTS], options: .fragmentsAllowed), encoding: .utf8)
                
                adunitsConfig?[tmpObj[Constants.ADUNIT] as! String] = tmpAdunitConfig
            }

            if #available(iOS 13.0, *) {
                cache?.save(Constants.ADUNITS_CONFIG_CACHE_KEY_NAME + "_" + networkCode, String(data:  try JSONSerialization.data(withJSONObject: adunitsConfig!, options: .withoutEscapingSlashes), encoding: .utf8))
            } else {
                cache?.save(Constants.ADUNITS_CONFIG_CACHE_KEY_NAME + "_" + networkCode, String(data:  try JSONSerialization.data(withJSONObject: adunitsConfig!, options: .fragmentsAllowed), encoding: .utf8))
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class ResponseHandler and method update", e)
        }
    }

    public func parseEventsConfig() -> Dictionary<String,Dictionary<String,Int>?>{
        var eventsConfig: Dictionary<String,Dictionary<String,Int>?> = [:]
        do{
            var event: String
            var adunit: String
            var tmpObjArr: [String:Any] = [:]
            var adunitEventsConfig: Dictionary<String,Int> = [:]

            var keys: Dictionary<String, Any?>.Keys.Iterator = adunitsConfig!.keys.makeIterator() // ?? [:].keys.makeIterator()
            
            while let rcKeysNextElement = keys.next(){
                adunit = rcKeysNextElement

                // 08 June 2021: Client reported crash error
                //var tmpObjItem = adunitsConfig![adunit] as! [String : String]
                //guard var tmpObjItem = adunitsConfig![adunit] as? [String : String] else {
                //    throw NSError(domain: "InvalidAdUnits", code: 0, userInfo: ["adunit":adunit])
                //}
                if var tmpObjItem = adunitsConfig![adunit] as? [String : String] {
                    tmpObjArr = try JSONSerialization.jsonObject(with: tmpObjItem[Constants.EVENTS]!.data(using: .utf8)!, options: .mutableContainers) as? [String : Int] ?? [:]
                }
                var events: Dictionary<String, Any>.Keys.Iterator = tmpObjArr.keys.makeIterator()
                while let rcEventsNextElement = events.next(){
                    event = rcEventsNextElement
                    adunitEventsConfig[event] = tmpObjArr[event] as? Int
                }
                eventsConfig[adunit] = adunitEventsConfig
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class ResponseHandler and method parseEventsConfig", e)
        }
        return eventsConfig
    }

    public func parseCustomTargetingKeys() -> Dictionary<String,Dictionary<String,String?>?>{
        var customTargetingKeys: Dictionary<String,Dictionary<String,String?>?> = [:]
        do{
            var tmpObj: [String:Any] = [:]
            var tmpObjArr: [[String:Any]] = [[:]]
            var adunit: String

            var keys: Dictionary<String, Any?>.Keys.Iterator = adunitsConfig!.keys.makeIterator()
            while let rcKeysNextElement = keys.next(){
                var adunitKeyValues: Dictionary<String,String?> = [:]
                adunit = rcKeysNextElement
                var tmpObjItem = adunitsConfig![adunit] as? [String : String] ?? [:]
                    
                tmpObjArr = try JSONSerialization.jsonObject(with: tmpObjItem[Constants.TARGETING]!.data(using: .utf8)!, options: .mutableContainers) as? [[String : Any]] ?? [[:]]
                
                for i in sequence( first: 0, next: { i in i + 1}).prefix( while: { i in i < tmpObjArr.count }) {
                    tmpObj = tmpObjArr[i]
                    
                    adunitKeyValues[tmpObj["key"] as? String ?? ""] = String(describing: tmpObj["value"] ?? "")
                }
                customTargetingKeys[adunit] = adunitKeyValues
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class ResponseHandler and method parseCustomTargetingKeys", e)
        }
        return customTargetingKeys
    }
}
