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

class CacheManager  {


    private var sharedPref: UserDefaults?

    init(_ networkCode: String){
        self.sharedPref = UserDefaults.standard
        self.sharedPref?.addSuite(named: Constants.CACHE_FILE_NAME)
        let cacheKeyName = Constants.ADUNITS_CONFIG_CACHE_KEY_NAME + "_" + networkCode
        
        if let v = sharedPref?.string(forKey: cacheKeyName) {
            // Key exit do nothing
        } else {
            save(cacheKeyName, "")  // To create the key if it is not present
        }
    }

    public func save(_ key: String?, _ value: String?) -> Void{
        if let editor: UserDefaults = sharedPref {
            editor.set( value == nil ? "nil" : value, forKey: key!)
            editor.synchronize()
        } else {
            sharedPref = UserDefaults.standard
            sharedPref?.addSuite(named: Constants.CACHE_FILE_NAME)
            sharedPref?.set( value == nil ? "nil" : value, forKey: key!)
            sharedPref?.synchronize()
        }
    }

    public func read(_ key: String?) -> String?{
        var value: String = ""
        if let k = key {
            do{
                if let v = sharedPref?.string(forKey: k) {
                    value = v
                } else {
                    throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
                }
            }
            catch let e as NSError {
                if TerceptOptimization.isDebugMode {
                    print("T: Error in CacheManager.read() for key = \(k)")
                }
                ErrorLogHandler.update("Error occurred in class CacheManager and method read for key = \(key ?? "NA")", e)
            }
        }
        return value
    }
}
