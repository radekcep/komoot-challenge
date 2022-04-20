//
//  DashboardViewModelTests.swift
//  Tests
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import XCTest

@testable import KomootChallenge

final class DashboardViewModelTests: XCTestCase {
  func test_sut_should_ask_for_image_every_100_meters() {
    let updatingLocationExpectation = expectation(description: "SUT should start updating location.")
    let photoURLsExpectation = expectation(description: "SUT should request photos 2 times.")
    photoURLsExpectation.expectedFulfillmentCount = 2
    let routeDistanceExpectation = expectation(description: "SUT should ask for distance 3 times.")
    routeDistanceExpectation.expectedFulfillmentCount = 3

    let locationsSubject = PassthroughSubject<Location, Never>()

    let locationClient = LocationClient(
      authorizationStatus: Empty().eraseToAnyPublisher(),
      locations: locationsSubject.eraseToAnyPublisher(),
      requestAuthorization: { XCTFail("Should not be called.") },
      startUpdatingLocation: { updatingLocationExpectation.fulfill() },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let photosClient = PhotosClient { _ in
      photoURLsExpectation.fulfill()

      return Just([URL(string: "https://example.com")!])
        .setFailureType(to: PhotosClient.Error.self)
        .eraseToAnyPublisher()
    }

    var distancesToReturn = [50.0, 100, 250]
    let routingClient = RoutingClient { _ in
      routeDistanceExpectation.fulfill()

      let distanceToReturn = distancesToReturn.first!
      distancesToReturn = Array(distancesToReturn.dropFirst())

      return distanceToReturn
    }

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: photosClient,
      routingClient: routingClient
    )

    sut.listenToLocationChanges()
    sut.startActivity()

    locationsSubject.send(.init(latitude: 0, longitude: 0))
    locationsSubject.send(.init(latitude: 0, longitude: 0))
    locationsSubject.send(.init(latitude: 0, longitude: 0))

    XCTAssertEqual(sut.photos.count, 2)
    waitForExpectations(timeout: 0.1)
  }

  func test_sut_should_update_title_with_every_distance_update() {
    let updatingLocationExpectation = expectation(description: "SUT should start updating location.")
    let routeDistanceExpectation = expectation(description: "SUT should ask for distance 3 times.")
    routeDistanceExpectation.expectedFulfillmentCount = 3

    let locationsSubject = PassthroughSubject<Location, Never>()

    let locationClient = LocationClient(
      authorizationStatus: Empty().eraseToAnyPublisher(),
      locations: locationsSubject.eraseToAnyPublisher(),
      requestAuthorization: { XCTFail("Should not be called.") },
      startUpdatingLocation: { updatingLocationExpectation.fulfill() },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    var distancesToReturn = [50.0, 100, 250]
    let routingClient = RoutingClient { _ in
      routeDistanceExpectation.fulfill()

      let distanceToReturn = distancesToReturn.first!
      distancesToReturn = Array(distancesToReturn.dropFirst())

      return distanceToReturn
    }

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: routingClient
    )

    sut.listenToLocationChanges()
    sut.startActivity()

    locationsSubject.send(.init(latitude: 0, longitude: 0))
    XCTAssertEqual(sut.title, "50m")

    locationsSubject.send(.init(latitude: 0, longitude: 0))
    XCTAssertEqual(sut.title, "100m")

    locationsSubject.send(.init(latitude: 0, longitude: 0))
    XCTAssertEqual(sut.title, "250m")

    waitForExpectations(timeout: 0.1)
  }
}

// MARK: - SUT should ask for location access

extension DashboardViewModelTests {
  func test_sut_should_ask_for_location_access_if_status_is_notDetermined() {
    let requestAuthorizationExpectation = expectation(description: "SUT should request authorization.")

    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: { requestAuthorizationExpectation.fulfill() },
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.notDetermined)

    waitForExpectations(timeout: 0.1)
  }

  func test_sut_should_ask_for_location_access_if_status_is_authorizedWhenInUse() {
    let requestAuthorizationExpectation = expectation(description: "SUT should request authorization.")

    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: { requestAuthorizationExpectation.fulfill() },
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.authorizedWhenInUse)

    waitForExpectations(timeout: 0.1)
  }
}

// MARK: - SUT should show warning when location access is unknown, restricted, denied, or authorizedWhenInUse

extension DashboardViewModelTests {
  func test_sut_should_show_warning_when_location_access_is_unknown() {
    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: { XCTFail("Should not be called.") },
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.unknown)

    XCTAssertFalse(sut.canStartActivity)
    XCTAssertNotNil(sut.warningText)
  }

  func test_sut_should_show_warning_when_location_access_is_restricted() {
    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: { XCTFail("Should not be called.") },
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.restricted)

    XCTAssertFalse(sut.canStartActivity)
    XCTAssertNotNil(sut.warningText)
  }

  func test_sut_should_show_warning_when_location_access_is_denied() {
    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: { XCTFail("Should not be called.") },
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.denied)

    XCTAssertFalse(sut.canStartActivity)
    XCTAssertNotNil(sut.warningText)
  }

  func test_sut_should_show_warning_when_location_access_is_notDetermined() {
    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: {},
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.notDetermined)

    XCTAssertFalse(sut.canStartActivity)
    XCTAssertNotNil(sut.warningText)
  }

  func test_sut_should_show_warning_when_location_access_is_authorizedWhenInUse() {
    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: {},
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.authorizedWhenInUse)

    XCTAssertFalse(sut.canStartActivity)
    XCTAssertNotNil(sut.warningText)
  }

  func test_sut_should_not_show_warning_when_location_access_is_authorizedAlways() {
    let authorizationStatusSubject = PassthroughSubject<LocationClient.AuthorizationStatus, Never>()

    let locationClient = LocationClient(
      authorizationStatus: authorizationStatusSubject.eraseToAnyPublisher(),
      locations: Empty().eraseToAnyPublisher(),
      requestAuthorization: {},
      startUpdatingLocation: { XCTFail("Should not be called.") },
      stopUpdatingLocation: { XCTFail("Should not be called.") }
    )

    let sut = DashboardViewModel(
      locationClient: locationClient,
      photosClient: .stub,
      routingClient: .stub
    )

    sut.requestPermissions()
    authorizationStatusSubject.send(.authorizedAlways)

    XCTAssertTrue(sut.canStartActivity)
    XCTAssertNil(sut.warningText)
  }
}
