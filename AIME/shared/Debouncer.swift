//
//  Debouncer.swift
//  AIME
//
//  Created by 李旭 on 2024/7/23.
//

import Foundation

actor Debouncer {
    private var currentTask: Task<Void, Never>?
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
    }

    deinit {
        assert(currentTask != nil)
        // even though the task is still retained,
        // once it completes it no longer causes a reference cycle with the actor

        print("deinit actor")
    }

    func debounce(action: @escaping @Sendable () async -> Void) {
        // 取消当前的任务（如果有）
        currentTask?.cancel()

        // 创建一个新的任务
        currentTask = Task {
            // 等待指定的延迟时间
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            // 在任务没有被取消的情况下执行操作
            if !Task.isCancelled {
               await action()
            }
        }
    }
}
