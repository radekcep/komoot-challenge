//
//  RoutingClient+live.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import CoreLocation
import Foundation

extension RoutingClient {
  static var live: Self {
    .init { locations in
      locations
        .map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        .reduce((distance: 0, latestLocation: CLLocation?.none)) { params, nextLocation in
          let pointsDistance = params.latestLocation?.distance(from: nextLocation) ?? 0
          let totalDistance = params.distance + pointsDistance

          return (totalDistance, nextLocation)
        }
        .distance
    }
  }
}
