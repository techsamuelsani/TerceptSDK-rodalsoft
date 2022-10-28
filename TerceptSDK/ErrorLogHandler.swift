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


class ErrorLogHandler  {

    private static let lock = DispatchSemaphore(value: 1)
    
    private static var _errorLogData: [String] = Array()
    private static var errorLogData: [String]{
        get {
            lock.wait()
            defer { lock.signal() }
            return _errorLogData
        }
        set{
            lock.wait()
            defer { lock.signal() }
            _errorLogData = newValue
        }
    }

    
    public static func update(_ message: String?, _ errorObject: NSError) -> Void{
        do{
            errorLogData.append(message ?? "" + "__" + getStackTrace(errorObject)!)
        }
        catch let e as NSError {
            errorLogData.append("Error occurred in class ErrorLogHandler and method update")
        }
    }

    public static func getData() -> [String?]{
        return ErrorLogHandler.errorLogData
    }

    public static func getDataAndReset() -> [String?]{
        var errorData = ErrorLogHandler.errorLogData
        ErrorLogHandler.errorLogData = [String]()
        return errorData
    }

    private static func getStackTrace(_ errorObject: NSError) -> String?{
        var stackTrace: String = ""
        do{
            let sw: String = String()
            var pw: String = sw
            pw = String(describing: Thread.callStackSymbols)
            stackTrace = pw
        }
        catch let e as NSError {
            errorLogData.append("Error occurred in class ErrorLogHandler and method getStackTrace")
        }
        return stackTrace
    }
}
