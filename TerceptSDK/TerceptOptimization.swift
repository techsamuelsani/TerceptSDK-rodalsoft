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

/**
Responsible for all the communication to and fro of the main app with the tercept optimization servers
- Author: Tercept
- Version: 3.0.7
*/
public class TerceptOptimization : NSObject {

    private let lock = DispatchSemaphore(value: 1)
    
    public static let sdkVersion = "3.0.7"
    public static var isDebugMode: Bool = false
    
    private var networkCode: String? = ""
    
    private var _eventHandler: EventsDataHandler?
    private var eventHandler: EventsDataHandler?{
        get {
            lock.wait()
            defer { lock.signal() }
            return _eventHandler
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _eventHandler = newValue
        }
    }
    
    private var _responseHandler: ResponseHandler?
    private var responseHandler: ResponseHandler? {
        get {
            lock.wait()
            defer { lock.signal() }
            return _responseHandler
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _responseHandler = newValue
        }
    }
    
    private var _customTargetingKeys: Dictionary<String,Dictionary<String,String?>?>?
    private var customTargetingKeys: Dictionary<String,Dictionary<String,String?>?>? {
        get {
            lock.wait()
            defer { lock.signal() }
            return _customTargetingKeys
        }
        set {
            lock.wait()
            defer { lock.signal() }
            _customTargetingKeys = newValue
        }
    }
    
    
    private var IDFA: String? = ""
    private var IDFV: String? = ""

    /**
    Starts the optimization for a particular network code (Deprecated)
    - Note Deprecated, this init function is for backword compatibility only
    - Parameter networkCode: DFP network code
    */
    public init(_ networkCode: String){
        self.networkCode = networkCode
        //self.customTargetingKeys = [:]
    }

    /**
    Initialises the SDK for advertising ID with a set of custom parameters
    - Note Deprecated, this function is for backword compatibility only
    - Parameter IDFA: Apple Identifier for advertisers
    - Parameter IDFV: Apple Identifier for vendor
    - Parameter params: A JSON object of custom parameters
    */
    public func initParams(_ IDFA: String, _ IDFV: String, _ params: [String:Any]?){
        self.IDFA = IDFA
        self.IDFV = IDFV
        CustomParams.set(Constants.defaultCustomParams)
        
        let cache: CacheManager = CacheManager(networkCode ?? "")
        eventHandler = EventsDataHandler()
        responseHandler = ResponseHandler(cache, networkCode ?? "")
        
        DeviceInfo.set()
        updateKeysAndEvents()
    }
    
    /**
     Starts the optimization for a particular network code and initialises the SDK for advertising ID with a set of custom parameters
    - Parameter networkCode: DFP network code
    - Parameter IDFA: Apple Identifier for advertisers
    - Parameter IDFV: Apple Identifier for vendor
    - Parameter params: A JSON object of custom parameters
    */
    public init(_ networkCode: String, _ IDFA: String, _ IDFV: String, _ params: [String:Any]?){
        super.init()
        self.networkCode = networkCode
        self.IDFA = IDFA
        self.IDFV = IDFV
        CustomParams.set(Constants.defaultCustomParams)
        
        let cache: CacheManager = CacheManager(networkCode)
        eventHandler = EventsDataHandler()
        responseHandler = ResponseHandler(cache, networkCode)
        
        DeviceInfo.set()
        updateKeysAndEvents()
    }

    /**
    Initialises the SDK for advertising ID with a set of default parameters
    - Note Deprecated, this function is for backword compatibility only
    - Parameter IDFA: Apple Identifier for advertisers
    - Parameter IDFV: Apple Identifier for vendor
    */
    public func initParams(_ IDFA: String, _ IDFV: String){
        self.IDFA = IDFA
        self.IDFV = IDFV

        CustomParams.set(Constants.defaultCustomParams)
        
        let cache: CacheManager = CacheManager(networkCode ?? "")
        eventHandler = EventsDataHandler()
        responseHandler = ResponseHandler(cache, networkCode ?? "")
        
        DeviceInfo.set()
        updateKeysAndEvents()
    }

    /**
    Starts the optimization for a particular network code and initialises the advertising ID with a set of default parameters
    - Parameter networkCode: DFP network code
    - Parameter IDFA: Apple Identifier for advertisers
    - Parameter IDFV: Apple Identifier for vendor
    */
        public init(_ networkCode: String, _ IDFA: String, _ IDFV: String){
            super.init()
            self.networkCode = networkCode
            self.IDFA = IDFA
            self.IDFV = IDFV
            
            CustomParams.set(Constants.defaultCustomParams)
            
            let cache: CacheManager = CacheManager(networkCode)
            eventHandler = EventsDataHandler()
            responseHandler = ResponseHandler(cache, networkCode)
            
            DeviceInfo.set()
            updateKeysAndEvents()
        }
    
    
    /**
    Initiates an asynchronous HTTPS GET request which obtains ad-unit specific configuration.
    - Parameter adunits: List of unique ad unit names to fetch configuration for
    */
    public func fetch(_ adunits: [String]?) -> Void{
        do{
            let url: URL = URLBuilder.build(Constants.requests.FETCH_SEGMENTS.description, networkCode, adunits, IDFA, IDFV)!

            let task: TaskRunner = TaskRunner<String>()

            task.executeAsync(SendGETRequest(url), TaskRunner_CallbackHandler<String>(parent: self))
            
            class TaskRunner_CallbackHandler<T>: TaskRunner_Callback{
                var parent: TerceptOptimization
                init(parent: TerceptOptimization){
                    self.parent = parent
                }
                
                func onComplete(result: T) -> Void {
                    let data = result as? String
                    do{
                        if data != nil {
                            if !(data!.isEmpty) {
                                parent.responseHandler?.update(data, parent.networkCode ?? "")
                                parent.updateKeysAndEvents()
                            } else {
                                throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
                            }
                        } else {
                            throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
                        }
                    }
                    catch let e as NSError {
                        ErrorLogHandler.update("Error occurred in class TerceptOptimization and method fetch", e)
                        if TerceptOptimization.isDebugMode {
                            print("Tercept: Error occurred in class TerceptOptimization and method fetch" + e.description)
                        }
                    }
                }
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class TerceptOptimization and method fetch", e)
            if TerceptOptimization.isDebugMode {
                print("Tercept: Error occurred in class TerceptOptimization and method fetch" + e.description)
            }
        }
    }

    /**
    Log events associated with an ad unit
    - Parameter adunit: String representing unique ad unit
    - Parameter event: Event name for the ad unit eg: onAdClicked, onAdClosed, onAdFailedToLoad, onAdImpression, onAdLeftApplication, onAdLoaded, onAdOpened, onFirstQuartile, onMidpoint, onThirdQuartile, onStarted, onSkipped
    - Returns: returns true if event capture was successful else false
    */
    public func logEvent(_ adunit: String?, _ event: String?) -> Bool{
        
        var success: Bool = eventHandler?.shouldLog(adunit, event)  ?? false
        
        do{
            eventHandler?.update(adunit!, event, CustomParams.get())
            success = true
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class TerceptOptimization and method logEvent", e)
        }
        return success
    }


    /**
    Log events associated with an ad unit along with custom parameters
    - Parameter adunit: String representing unique ad unit
    - Parameter event: Event name for the ad unit eg: onAdClicked, onAdClosed, onAdFailedToLoad, onAdImpression, onAdLeftApplication, onAdLoaded, onAdOpened, onFirstQuartile, onMidpoint, onThirdQuartile, onStarted, onSkipped
    - Parameter customParams: Custom parameters to pass with respected to this event
    - Returns: returns true if event capture was successful else false
    */
    public func logEvent(_ adunit: String?, _ event: String?, _ customParams: [String:Any]) -> Bool{
        var success: Bool = eventHandler?.shouldLog(adunit, event)  ?? false
        
        do{
            eventHandler?.update(adunit!, event, customParams)
            success = true
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class TerceptOptimization and method logEvent", e)
        }
        return success
    }
    
    
    /**
    Prints the JSON object with all the events currently logged and ready to be sent to tercept servers
    - Returns: returns JSON object containing logged events not sent till now
    */
    public func getEventsData() -> [String:Any]?{
        return eventHandler?.getData()
    }
    
    
    /**
    Send the events data logged using logEvent to tercept servers - to be done at end of each user session
    */
    public func sendEventsData() -> Void{
        
        // 31 Juy 2021: If there are no events then do not continue send data
        if let trackingDt: [[String:Any?]] = eventHandler!.getData()["tracking"] as? [[String : Any?]] {
            if trackingDt.count == 0 {
                return
            }
        } else {
            return
        }
        
        let url: URL = URLBuilder.build(Constants.requests.LOG_EVENT.description, networkCode, "adunit", IDFA, IDFV, "eventLog")!
        
        let task: TaskRunner = TaskRunner<String>()
        
        task.executeAsync(SendPOSTRequest(url, eventHandler!.getAndResetEventsData()), TaskRunner_CallbackHandler<String>(parent: self))
        
        class TaskRunner_CallbackHandler<T>: TaskRunner_Callback{
            var parent: TerceptOptimization
            init(parent: TerceptOptimization){
                self.parent = parent
            }
            
            func onComplete(result: T) -> Void {
                let data = result as? String
                if data != nil {
//                    if !(data!.isEmpty) {
//                    } else {
//                        //throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
//                    }
                }
           
            }
            
        }

 
    }

    /**
    Sets custom parameters to be passed for tercept like web url, user or page specific data to optimise campaign better
    - Parameter params: params as a JSON object key and value with multiple keys
    */
    public func setCustomParameters(_ params: [String:String]){
        CustomParams.set(params)
    }
    
    /**
    Gets targeting keys to be sent for a particular ad unit - must be called before building each ad request
    - Parameter adunit: String representing unique ad unit
    - Returns: returns sets of keys and values which are to be added to the ad builder request
    */
    public func getCustomTargetingKeys(_ adunit: String?) -> Dictionary<String,String?>{

        var adunitKeyValues: Dictionary<String,String?> = Constants.defaultCustomTargetingKey
        do{
            if customTargetingKeys != nil && adunit != nil {
                if !(customTargetingKeys!.isEmpty) {
                    if customTargetingKeys!.contains(where: { key, value in key ?? "" == String(adunit!)}) {
                        adunitKeyValues = customTargetingKeys![adunit!]!!
                    } else {
                        throw NSError(domain: "customTargetingKeys-KeyNotFound", code: 0, userInfo: nil)
                    }
                }else {
                    throw NSError(domain: "customTargetingKeys-isEmpty", code: 0, userInfo: nil)
                }
            }else {
                throw NSError(domain: "customTargetingKeys-isNil", code: 0, userInfo: nil)
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class TerceptOptimization and method getCustomTargetingKeys for adunit = \(adunit ?? "Nil") : \(e.domain)", e)
            adunitKeyValues = Constants.defaultCustomTargetingKey
        }
        return adunitKeyValues
    }

    /**
    Update keys and events being used internally for custom targeting using tercept optimization
    */
    private func updateKeysAndEvents() -> Void{
        do{
            if let keys = responseHandler?.parseCustomTargetingKeys() {
                customTargetingKeys = keys
            } else {
                throw NSError(domain: "customTargetingKeys", code: 0, userInfo: nil)
            }
            
            eventHandler?.setEventsConfig((responseHandler!.parseEventsConfig()))
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class TerceptOptimization and method updateKeysAndEvents", e)
        }
    }
}

