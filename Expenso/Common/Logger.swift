//
//  Logger.swift
//  Expenso
//
//  Created by Eugene Ned on 23.11.2023.
//

import Foundation

enum LogLevel {
    case debug
    case error
    case warning
    case info
}

private extension LogLevel {

    var emoji: String {
        switch self {
        case .debug: return "🤖"
        case .error: return "🤯"
        case .warning: return "🧐"
        case .info: return "ℹ️"
        }
    }
}

private let loggerQueue = DispatchQueue(label: "expenso.loggerQueue")

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "[dd-MM-yyyy, hh:mm:ss.SSS]"
    return formatter
}()

func logger(
    tag: String = "",
    message: @autoclosure () -> String,
    level: LogLevel,
    passedCheck: Bool? = nil,
    function _: String = #function,
    file _: String = #file,
    line _: Int = #line
) {
    #if DEBUG
    var checkEmoji: String {
        guard let check = passedCheck else { return "" }
        return check ? " ✅" : " ❌"
    }
    
    let msg = message()
    loggerQueue.async {
        let formattedDate = dateFormatter.string(from: Date())
        if tag.isEmpty {
            print(level.emoji, formattedDate, msg, checkEmoji)
        } else {
            print(level.emoji, formattedDate, tag + ":", msg, checkEmoji)
        }
    }
    #endif
}
