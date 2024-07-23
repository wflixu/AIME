//
//  AppLog.swift
//  AIME
//
//  Created by lixu on 2024/7/16.
//

import Foundation

import os.log

@propertyWrapper
struct AppLog {
    private let logger: Logger

    init(subsystem: String = "cn.wflixu.aime", category: String = "aime") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    var wrappedValue: Logger {
        return logger
    }
}
