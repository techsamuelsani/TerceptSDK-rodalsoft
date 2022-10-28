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

class SendGETRequest: Callable {


    private var url: URL?

    init(_ url: URL){
        self.url = url
    }

    public func call() -> String?{
        var response: String

        var conn: URLRequest = URLRequest(url: url!)
        
        var userAgent: String? = ""
        DispatchQueue.main.sync {
            userAgent = UserAgent.get() ?? ""
        }
        
        if userAgent != nil {
            if !(userAgent!.isEmpty) {
                conn.addValue(userAgent!, forHTTPHeaderField: "User-Agent")
            }
        }
        
        // 21 July 2021: Added below two headers
        // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control
        // Cache-Control: no-cache
        // Cache-Control: max-age=<seconds>   // max-age needs to be numeric value, but API takes string only
        // Expires: Wed, 21 Oct 2015 07:28:00 GMT
        conn.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
        if TerceptOptimization.isDebugMode {
            //conn.addValue(120, forHTTPHeaderField: "max-age")
            conn.setValue("0", forHTTPHeaderField: "max-age")
        } else {
            //conn.addValue("900", forHTTPHeaderField: "Expires")
            conn.setValue("0", forHTTPHeaderField: "max-age")
        }
        
        // print("conn.allHTTPHeaderFields = \(conn.allHTTPHeaderFields)")
        
        if TerceptOptimization.isDebugMode {
            print(" > Tercept: SendGETRequest.url = \(url?.absoluteString ?? "Err")")
            print(" > Tercept: SendGETRequest.call(), userAgent = " + userAgent!)
        }
        
        var inData: Data? = nil
        var connHTTPMetaData: HTTPURLResponse?
        let rcSemaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: conn, completionHandler: { (data, response, error) in
            inData = data
            connHTTPMetaData = response as? HTTPURLResponse
            rcSemaphore.signal()
        }).resume()
        
        rcSemaphore.wait()

        var stringBuilder: String = String()
        if let data = inData {
            var reader: IndexingIterator = (String(bytes: data, encoding: .utf8)!.components(separatedBy: .newlines)).makeIterator()
            var line: String?
            
            line = reader.next()
            while line != nil {
                stringBuilder += line!
                line = reader.next()
            }

        }
        response = stringBuilder
        if TerceptOptimization.isDebugMode {
            print(" < Tercept: SendGETRequest.call(), statusCode = \(connHTTPMetaData?.statusCode ?? 0), response = \(response)")
        }
        
        return response
   
    }
}
