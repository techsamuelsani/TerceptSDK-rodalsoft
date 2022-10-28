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

class DeviceInfo  {

    private static let lock = DispatchSemaphore(value: 1)
    
    public static var _DEVICE_INFO: [String:Any] = [String:Any]()
    public static var DEVICE_INFO: [String:Any]{
        get {
            lock.wait()
            defer { lock.signal() }
            return _DEVICE_INFO
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _DEVICE_INFO = newValue
        }
    }

    public static func set() -> Void{
        var info: [String:Any] = [String:Any]()
        do{
            info["MODEL"] = UIDevice.modelName
            info["MANUFACTURER"] = "Apple"
            info["SDK"] = UIDevice.current.systemVersion
            info["iOS_VERSION"] = UIDevice.current.systemVersion
            info["APP_VERSION"] = DeviceInfo.getVersionName()
            info["APP_NAME"] = DeviceInfo.getApplicationName()
            DEVICE_INFO = info
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class DeviceInfo and method set", e)
        }
    }

    private static func getApplicationName() -> String?{
        var applicationName: String = "Unknown"
        do{
            let applicationInfo: Bundle = Bundle.main
            
            let stringId: Int = 0
            
            applicationName = (stringId == 0 ? applicationInfo.bundleIdentifier ?? "" : "app_name")
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class DeviceInfo and method set", e)
        }
        return applicationName
    }

    private static func getVersionName() -> String?{
        var versionName: String = "Unknown"
        do{
            if let v = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                versionName = v
            } else {
               throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
           }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class DeviceInfo and method getVersionName", e)
        }
        return versionName
    }
}
