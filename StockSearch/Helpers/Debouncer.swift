//
//  Debouncer.swift
//  StockSearch
//
//  Created by William Choi on 11/27/20.
//
//https://github.com/onmyway133/Omnia/blob/master/Sources/Shared/Debouncer.swift

import Foundation

public class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    public init(delay: TimeInterval) {
        self.delay = delay
    }

    /// Trigger the action after some delay
    public func run(action: @escaping () -> Void) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: action)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
}
