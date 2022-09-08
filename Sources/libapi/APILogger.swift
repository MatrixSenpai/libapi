//
//  APILogger.swift
//  
//
//  Created by Mason Phillips on 9/7/22.
//

import Foundation

public protocol APILogger {
    var level: LogLevel { get set }

    func verbose(_ message: String, file: String, function: String, line: Int)
    func debug(_ message: String, file: String, function: String, line: Int)
    func info(_ message: String, file: String, function: String, line: Int)
    func warning(_ message: String, file: String, function: String, line: Int)
    func error(_ message: String, file: String, function: String, line: Int)
}

public enum LogLevel: Int, Equatable, Comparable, CustomStringConvertible {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4

    public var description: String {
        switch self {
        case .verbose: return "VERBOSE"
        case .debug  : return "DEBUG"
        case .info   : return "INFO"
        case .warning: return "WARNING"
        case .error  : return "ERROR"
        }
    }

    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

open class DefaultLogger: APILogger {
    public var level: LogLevel

    public init(logLevel: LogLevel = .verbose) {
        self.level = logLevel
    }

    public func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        self.consoleMessage(messageLevel: .verbose, message, file: file, function: function, line: line)
    }
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        self.consoleMessage(messageLevel: .debug, message, file: file, function: function, line: line)
    }
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        self.consoleMessage(messageLevel: .info, message, file: file, function: function, line: line)
    }
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        self.consoleMessage(messageLevel: .warning, message, file: file, function: function, line: line)
    }
    public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        self.consoleMessage(messageLevel: .error, message, file: file, function: function, line: line)
    }

    private func consoleMessage(messageLevel: LogLevel, _ message: String, file: String, function: String, line: Int) {
        if messageLevel >= level {
            print("[\(level.description)] (\(file) L\(line)) \(function):  \(message)")
        }
    }
}
