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

public protocol  Callable {
    associatedtype R
    func call() -> R
}

public protocol TaskRunner_Callback {
    associatedtype R
    func onComplete(result: R) -> Void
}

class TaskRunner<R>  {
    
    // 21 July 2021: DispatchQueue.global() error: nw_protocol_get_quic_image_block_invoke dlopen libquic failed
    private let executor: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
    
    private let handler: DispatchQueue = DispatchQueue(label: "main")

    public func executeAsync< C: Callable, T: TaskRunner_Callback>( _ callable: C, _ callback: T) -> Void{
        
        executor.async( execute: { [self] () -> Void in
            var result: R?
            do{
                if let r = callable.call() as? R {
                    result = r
                } else {
                    throw NSError(domain: "TerceptSDK", code: 0, userInfo: nil)
                }
            }
            catch let e as NSError {
                if TerceptOptimization.isDebugMode {
                    print("---\nTercept: " + String(describing: Thread.callStackSymbols))
                }
            }
            let finalResult: R = result!
            handler.async( execute: { [self] () -> Void in
                callback.onComplete(result: finalResult as! T.R)
            })

        })

    }

}
