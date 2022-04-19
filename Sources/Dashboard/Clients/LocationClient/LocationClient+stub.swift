#if DEBUG
//
//  LocationClient+stub.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

extension LocationClient {
  static var stub: Self {
    .init(
      authorizationStatus: Empty().eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: {},
      startUpdatingLocation: {},
      stopUpdatingLocation: {}
    )
  }
}
#endif
