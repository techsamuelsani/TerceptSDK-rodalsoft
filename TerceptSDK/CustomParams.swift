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


class CustomParams : NSObject {

    private static let lock = DispatchSemaphore(value: 1)
    
    private static var _customParams: [String:String]? = [:]
    private static var customParams: [String:String]?{
        get {
            lock.wait()
            defer { lock.signal() }
            return _customParams
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _customParams = newValue
        }
    }

    public static func set(_ params: [String:String]) -> Void{
        customParams = params
    }

    public static func get() -> [String:String]{
        return customParams!
    }

    override public var description: String {
        var params: String = "{}"
        do{
            if #available(iOS 13.0, *) {
                params = String(data: try JSONSerialization.data(withJSONObject: CustomParams.customParams!, options: .withoutEscapingSlashes), encoding: .utf8) ?? ""
            } else {
                params = String(data: try JSONSerialization.data(withJSONObject: CustomParams.customParams!, options: .fragmentsAllowed), encoding: .utf8) ?? ""
            }
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class CustomParams and method ToString", e)
        }
        return params
    }
}
