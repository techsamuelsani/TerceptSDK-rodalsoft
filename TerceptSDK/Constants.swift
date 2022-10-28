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

class Constants  {

    //Default response for custom targeting keys
    public static let defaultCustomTargetingKey: Dictionary<String,String> = {
        var defaultCustomTargetingKeyItem = ["tcpt" : "TCPT_NL"]
        return defaultCustomTargetingKeyItem
    }()
    //Default response for events config
    public static let defaultEventsConfig: Dictionary<String?,Int> = {
        var defaultEventsConfig: Dictionary<String?,Int> = [:]
        
        // 22 July 2021: Change the default value to 1 to handle fresh install case
        // When app is freshly installed cache is zero and in this case no events are logged until first fetch() request is maid
        // To prevent loss of data below two events will get logged by default
        defaultEventsConfig["onAdImpression"] = 0
        defaultEventsConfig["onAdClicked"] = 0

        defaultEventsConfig["onAdClosed"] = 0
        defaultEventsConfig["onAdFailedToLoad"] = 0
        defaultEventsConfig["onAdLeftApplication"] = 0
        defaultEventsConfig["onAdLoaded"] = 0
        defaultEventsConfig["onAdOpened"] = 0
        defaultEventsConfig["onFirstQuartile"] = 0
        defaultEventsConfig["onMidpoint"] = 0
        defaultEventsConfig["onThirdQuartile"] = 0
        defaultEventsConfig["onStarted"] = 0
        defaultEventsConfig["onSkipped"] = 0
        return defaultEventsConfig
    }()
    //Default custom params
    public static var defaultCustomParams: [String:String] = [String:String]()
    //URL related constants
    public static let FETCH_SEGMENTS_DOMAIN: String = "https://serve.tercept.com/"
    public static let LOGS_DOMAIN: String = "https://b-s.tercept.com/"
    public static let FETCH_SEGMENTS_PATH: String = "webview/segment"
    public static let LOGS_PATH: String = "applogs"
    public static let EVENT_TYPE: String = "e_c="
    public static let NETWORK_ID: String = "n_id="
    public static let AD_UNITS: String = "a_id="
    public static let DEVICE_ID: String = "d_id="
    public static let VENDOR_ID: String = "v_id="
    public static let FIXED_PARAMS: String = "f_p="
    public static let CUSTOM_PARAMS: String = "c_p="
    //Object keys in server response
    public static let EVENTS: String = "events"
    public static let TARGETING: String = "targeting"
    public static let ADUNIT: String = "adunitid"
    //Cache related constants
    public static let CACHE_FILE_NAME: String = "tercept"
    public static let ADUNITS_CONFIG_CACHE_KEY_NAME: String = "adunitsData"
    //Event IDs
    public static let eventIDs: Dictionary<String?,Int> = {
        var eventIDsItems: Dictionary<String?,Int> = [:]
        eventIDsItems["onAdClicked"] = 0
        eventIDsItems["onAdClosed"] = 1
        eventIDsItems["onAdFailedToLoad"] = 2
        eventIDsItems["onAdImpression"] = 3
        eventIDsItems["onAdLeftApplication"] = 4
        eventIDsItems["onAdLoaded"] = 5
        eventIDsItems["onAdOpened"] = 6
        eventIDsItems["onFirstQuartile"] = 7
        eventIDsItems["onMidpoint"] = 8
        eventIDsItems["onThirdQuartile"] = 9
        eventIDsItems["onStarted"] = 10
        eventIDsItems["onSkipped"] = 11
        return eventIDsItems
    }()
    //Bool values used for events
    public static let TRUE: Int = 1

    //Type of request
    public enum requests: Int, CustomStringConvertible {
        case FETCH_SEGMENTS, LOG_EVENT, LOG_ERROR ;
        public var description: String {
            switch self {
            case .FETCH_SEGMENTS: return "FETCH_SEGMENTS"
            case .LOG_ERROR: return "LOG_ERROR"
            case .LOG_EVENT : return "LOG_EVENT"
            }
        }
        
    }
}
