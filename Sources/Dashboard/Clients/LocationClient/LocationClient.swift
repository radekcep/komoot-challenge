//
//  LocationClient.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

struct LocationClient {
  let authorizationStatus: AnyPublisher<AuthorizationStatus, Never>
  let locations: AnyPublisher<Location, Never>
  let requestAuthorization: () -> Void
  let startUpdatingLocation: () -> Void
  let stopUpdatingLocation: () -> Void
}

extension LocationClient {
  enum AuthorizationStatus {
    case unknown, notDetermined, restricted, denied, authorizedAlways, authorizedWhenInUse
  }
}
