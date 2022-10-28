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
import WebKit
import SafariServices

class UserAgent  {

    public static var userAgentString: String = ""
    
    public static func get() -> String?{
        var userAgent: String = ""
        
        if UserAgent.userAgentString == "" && UserAgent.userAgentString != "fetching..." {
            // Its a first call to get UA String
            UserAgent.userAgentString = "fetching..."
            
            // UA String is not yet fetched, return generated string and start fetching
            userAgent = generateUA()
            UserAgent.userAgentString = userAgent
            
            // 16 June 2021: On iOS 14.5 this code logs the below exceltion -
            // 1) ProcessAssertion: Failed to acquire RBS Background assertion 'WebProcess Background Assertion'
            // 2) Target is not running or required target entitlement is missing
            // Solution: Enable background Modes in 'Signing & Capabilities' tab
            //      a) Audio, AirPay, and PnP
            //      b) Voice over IP
            //      c) Background processing
            // Problem with this solution: App store review may reject app for using capability which is not directly related to functionality
                        
//            var webViewForUserAgent = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
//            webViewForUserAgent.translatesAutoresizingMaskIntoConstraints = false
//            var parent = UIView(frame: .zero)
//
//            parent.addSubview(webViewForUserAgent)
//            webViewForUserAgent.evaluateJavaScript("navigator.userAgent") { (result, error) in
//                    if error != nil {
//                        return
//                    }
//
//                    if let unwrappedUserAgent = result as? String {
//                        userAgent = unwrappedUserAgent
//                        UserAgent.userAgentString = userAgent
//                    }
//                }
            
        } else if UserAgent.userAgentString == "fetching..." {
            // UA String fetching in progress, return generated string
            userAgent = generateUA()
            
        } else {
            // UA String is fetched, return actual UA string
            userAgent = UserAgent.userAgentString
        }
        
        return userAgent
    }
    
    private static func generateUA() -> String {
        // Function to generate the UA string based on device information
        var devInf = DeviceInfo.set()
//        var uaString = "("
//
//        if let val = DeviceInfo.DEVICE_INFO["MANUFACTURER"] as? String {
//            uaString.append(val + ";")
//        }
//        if let val = DeviceInfo.DEVICE_INFO["MODEL"] as? String {
//            uaString.append(val + ";")
//        }
//        if let val = DeviceInfo.DEVICE_INFO["iOS_VERSION"] as? String {
//            uaString.append(val + ")")
//        }
        
        var uaString = "Mozilla/5.0 ("
        if let val = DeviceInfo.DEVICE_INFO["MODEL"] as? String {
            uaString.append(val + "; ")
        }

        uaString.append("CPU ")

        if let val = DeviceInfo.DEVICE_INFO["MODEL"] as? String {
            uaString.append(val + " like Mac OS X)")
        }

        uaString.append(" AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148")

        return uaString
    }
}

