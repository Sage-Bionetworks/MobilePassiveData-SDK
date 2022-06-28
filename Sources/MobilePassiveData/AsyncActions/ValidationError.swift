//
//  ValidationError.swift
//  
//
//  Copyright © 2017-2021 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

/// `ValidationError` is a catch-all for different types of errors that occur during
/// validation of a decoded or encoded object.
///
public enum ValidationError : CustomNSError, LocalizedError {
    
    /// Attempting to load a section, task, or input form with non-unique identifiers.
    case notUniqueIdentifiers(String)
    
    /// Expected identifier was not found.
    case identifierNotFound(identifier: String, String)
    
    /// Unsupported data type.
    case invalidType(String)
    
    /// The value provided does not unwrap into an expected type.
    case invalidValue(value: Any?, String)

    /// A forced optional unwrapped with a nil value.
    case unexpectedNullObject(String)
    
    /// The domain of the error.
    public static var errorDomain: String {
        return "MPDValidationErrorDomain"
    }
    
    /// The error code within the given domain.
    public var errorCode: Int {
        switch(self) {
        case .notUniqueIdentifiers(_):
            return -1
        case .invalidType(_):
            return -5
        case .identifierNotFound(_, _):
            return -6
        case .unexpectedNullObject(_):
            return -7
        case .invalidValue(_, _):
            return -8
        }
    }
    
    /// The user-info dictionary.
    public var errorUserInfo: [String : Any] {
        let description: String
        switch(self) {
        case .notUniqueIdentifiers(let str): description = str
        case .invalidType(let str): description = str
        case .identifierNotFound(_, let str): description = str
        case .unexpectedNullObject(let str): description = str
        case .invalidValue(_, let str): description = str
        }
        return ["NSDebugDescription": description]
    }
}
