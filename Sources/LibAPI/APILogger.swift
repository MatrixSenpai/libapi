//
//  APILogger.swift
//  
//
//  Created by Mason Phillips on 5/9/23.
//

import Foundation

public protocol APILogger {
    func verbose(_ message: Any)
    func verbose(_ message: @autoclosure () -> Any, file: String, function: String, line: Int, context: Any?)
    func debug(_ message: Any)
    func debug(_ message: @autoclosure () -> Any, file: String, function: String, line: Int, context: Any?)
    func info(_ message: Any)
    func info(_ message: @autoclosure () -> Any, file: String, function: String, line: Int, context: Any?)
    func warning(_ message: Any)
    func warning(_ message: @autoclosure () -> Any, file: String, function: String, line: Int, context: Any?)
    func error(_ message: Any)
    func error(_ message: @autoclosure () -> Any, file: String, function: String, line: Int, context: Any?)
}
