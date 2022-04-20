//
//  LocationClient+live.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import CoreLocation
import Foundation

extension LocationClient {
  static var live: Self {
    let locationManagerDelegate = LocationManagerDelegate()

    let locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.delegate = locationManagerDelegate

    return .init(
      authorizationStatus: Deferred {
        Just(locationManager.authorizationStatus)
          .merge(with: locationManagerDelegate.didChangeAuthorizationSubject
            .map(\.authorizationStatus))
      }
        .map(AuthorizationStatus.init)
        .eraseToAnyPublisher(),
      locations: locationManagerDelegate.didUpdateLocationsSubject
        .compactMap { $1.first.map(Location.init) }
        .eraseToAnyPublisher(),
      requestAuthorization: locationManager.requestAlwaysAuthorization,
      startUpdatingLocation: locationManager.startUpdatingLocation,
      stopUpdatingLocation: locationManager.stopUpdatingLocation
    )
  }
}

private extension LocationClient {
  class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var didChangeAuthorizationSubject = PassthroughSubject<CLLocationManager, Never>()
    var didUpdateLocationsSubject = PassthroughSubject<(CLLocationManager, [CLLocation]), Never>()

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      didChangeAuthorizationSubject.send(manager)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      didUpdateLocationsSubject.send((manager, locations))
    }
  }
}

private extension LocationClient.AuthorizationStatus {
  init(from clAuthorizationStatus: CLAuthorizationStatus) {
    switch clAuthorizationStatus {
    case .notDetermined:
      self = .notDetermined
    case .restricted:
      self = .restricted
    case .denied:
      self = .denied
    case .authorizedAlways:
      self = .authorizedAlways
    case .authorizedWhenInUse:
      self = .authorizedWhenInUse
    @unknown default:
      self = .unknown
    }
  }
}

private extension Location {
  init(from clLocation: CLLocation) {
    self.latitude = clLocation.coordinate.latitude
    self.longitude = clLocation.coordinate.longitude
  }
}
