//
//  NavigatingViewModel.swift
//  NewsFeed
//
//  Created by Vladimir Orlov on 21.04.2025.
//

import Foundation
import Combine

protocol NavigatingViewModel {
    associatedtype Step
    var navigationStepPublisher: AnyPublisher<Step, Never> { get }
}
