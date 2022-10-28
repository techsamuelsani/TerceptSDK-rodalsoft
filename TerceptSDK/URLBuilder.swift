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

class URLBuilder  {
  
    public static func build(_ type: String?, _ networkCode: String?, _ adunits: [String]?, _ deviceId: String?, _ vendorId: String?) -> URL?{
        var url: URL? = nil
        do{
            if type == Constants.requests.FETCH_SEGMENTS.description {
                var adunitsAsString: String = adunits!.description.replacingOccurrences(of: "[", with: "")
                    .replacingOccurrences(of: "]", with: "")
                    .replacingOccurrences(of: ", ", with: ",")
                    .replacingOccurrences(of: "\"", with: "")
                
                var DEVICE_INFO_JSON = ""
                do{
                    DEVICE_INFO_JSON = String(data: (try JSONSerialization.data(withJSONObject: DeviceInfo.DEVICE_INFO, options: .fragmentsAllowed)), encoding: .utf8) ?? "Err"
                } catch let ex as NSError {
                    DEVICE_INFO_JSON = "Err"
                }
                
                var urlPath: String = Constants.FETCH_SEGMENTS_DOMAIN + Constants.FETCH_SEGMENTS_PATH + "?"
                    + Constants.NETWORK_ID + networkCode!
                    + "&" + Constants.AD_UNITS + adunitsAsString
                    + "&" + Constants.DEVICE_ID + deviceId!
                    + "&" + Constants.VENDOR_ID + vendorId!
                    + "&" + Constants.FIXED_PARAMS + DEVICE_INFO_JSON
                    + "&" + Constants.CUSTOM_PARAMS + CustomParams.description()

                urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                do {
                    url = try URL(validURL: urlPath)!
                } catch {
                    if TerceptOptimization.isDebugMode {
                        print("Tercept: " + error.localizedDescription)
                    }
                }
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class URLlBuilder and method build", e)
        }
        return url
    }

    public static func build(_ type: String?, _ networkCode: String?, _ adunit: String?, _ deviceId: String?, _ vendorId: String?, _ event: String?) -> URL?{
        var url: URL? = nil
        do{
            if type == Constants.requests.LOG_EVENT.description {
                var urlPath:String = Constants.LOGS_DOMAIN + Constants.LOGS_PATH + "?"
                    + Constants.NETWORK_ID + networkCode!
                    + "&" + Constants.AD_UNITS + adunit!
                    + "&" + Constants.DEVICE_ID + deviceId!
                    + "&" + Constants.VENDOR_ID + vendorId!
                    + "&" + Constants.EVENT_TYPE
                    + event!
                
                urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                url = try URL(validURL: urlPath)!
            }
            else if type == Constants.requests.LOG_ERROR.description {
                let urlPath = Constants.LOGS_DOMAIN + Constants.LOGS_PATH + "?"
                    + Constants.NETWORK_ID + networkCode!
                    + "&" + Constants.AD_UNITS + adunit!
                    + "&" + Constants.DEVICE_ID + deviceId!
                    + "&" + Constants.VENDOR_ID + vendorId!
                    + "&" + Constants.EVENT_TYPE + "error"
                url = try URL(validURL: urlPath)!
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class URLlBuilder and method build", e)
        }
        return url
    }
}
