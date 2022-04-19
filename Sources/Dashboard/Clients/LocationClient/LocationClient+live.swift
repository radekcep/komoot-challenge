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
    let authorizationStatusSubject = PassthroughSubject<AuthorizationStatus, Never>()
    let locationsSubject = PassthroughSubject<Location, Never>()

    let locationManagerDelegate = LocationManagerDelegate()
    locationManagerDelegate.didChangeAuthorization = { locationManager in
      authorizationStatusSubject.send(AuthorizationStatus(from: locationManager.authorizationStatus))
    }
    locationManagerDelegate.didUpdateLocations = { _, locations in
      locations.first.map { locationsSubject.send(Location(from: $0)) }
    }

    let locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.delegate = locationManagerDelegate

    locationManager.requestAlwaysAuthorization()

    return .init(
      authorizationStatus: Deferred { Just(AuthorizationStatus(from: locationManager.authorizationStatus)) }
        .merge(with: authorizationStatusSubject)
        .eraseToAnyPublisher(),
      locations: locationsSubject.eraseToAnyPublisher(),
      requestAuthorization: locationManager.requestAlwaysAuthorization,
      startUpdatingLocation: locationManager.startUpdatingLocation,
      stopUpdatingLocation: locationManager.stopUpdatingLocation
    )
  }
}

private extension LocationClient {
  class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var didChangeAuthorization: ((CLLocationManager) -> Void)?
    var didUpdateLocations: ((CLLocationManager, [CLLocation]) -> Void)?

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
      didChangeAuthorization?(manager)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      didUpdateLocations?(manager, locations)
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
