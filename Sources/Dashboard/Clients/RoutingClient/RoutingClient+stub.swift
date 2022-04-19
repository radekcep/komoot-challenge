#if DEBUG
//
//  RoutingClient+stub.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

extension RoutingClient {
  static var stub: Self {
    .init { _ in 0 }
  }
}

#endif
