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

class SendPOSTRequest: Callable {

    private var url: URL?
    private var data: [String:Any]? = [:]

    init(_ url: URL, _ data: [String:Any]){
        self.url = url
        self.data = data
//        if TerceptOptimization.isDebugMode {
//            print("---\nTercept: SendPOSTRequest.init(),  url = " + self.url!.absoluteString ?? "Empty")
//            print("Tercept: SendPOSTRequest.init(), data = " + self.data!.description ?? "No Data")
//            print("---")
//        }
    }

    public func call() -> String?{
        do{
            var response: String

            var conn: URLRequest = URLRequest(url: url!)
            try conn.validateAndSetHTTPMethod(method: "POST")
            conn.httpBody = try! JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
            
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
            // 'Cache-Control': 'no-cache',
            // 'Expires': 0
            conn.addValue("no-cache", forHTTPHeaderField: "Cache-Control")
            if TerceptOptimization.isDebugMode {
                conn.addValue("0", forHTTPHeaderField: "max-age")
            } else {
                conn.addValue("900", forHTTPHeaderField: "max-age")
            }
            

            if TerceptOptimization.isDebugMode {
                print(" > Tercept: SendPOSTRequest.call(), userAgent = " + userAgent!)
                print(" > Tercept: SendPOSTRequest.call(),      data = " + data!.debugDescription)
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
                    stringBuilder += line ?? ""
                    line = reader.next()
                }
            }
            response = stringBuilder
            
            if TerceptOptimization.isDebugMode {
                print(" < Tercept: SendPOSTRequest.call(), statusCode = \(connHTTPMetaData?.statusCode ?? 0), response = \(response)")
            }
            
            return response
        }
        catch let e as NSError {
            ErrorLogHandler.update("Error occurred in class SendPOSTRequest and method call", e)
        }
        return nil
    }
}
