//
//  DashboardViewModel.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

class DashboardViewModel: ObservableObject {
  private let distanceToPhotoTreshold: Double
  private let uuid: () -> UUID
  private let locationClient: LocationClient
  private let photosClient: PhotosClient
  private let routingClient: RoutingClient

  @Published var title: String?
  @Published var warningText: String?
  @Published var photos: [Photo] = []
  @Published var canStartActivity: Bool = false
  @Published var isActivityInProgress: Bool = false

  init(
    uuid: @escaping () -> UUID = UUID.init,
    distanceToPhotoTreshold: Double = 100,
    locationClient: LocationClient,
    photosClient: PhotosClient,
    routingClient: RoutingClient
  ) {
    self.uuid = uuid
    self.distanceToPhotoTreshold = distanceToPhotoTreshold
    self.locationClient = locationClient
    self.photosClient = photosClient
    self.routingClient = routingClient
  }

  func requestPermissions() {
    let authorizationStatus = locationClient.authorizationStatus
      .handleEvents(
        receiveOutput: { [weak self] authorizationStatus in
          switch authorizationStatus {
          case .notDetermined, .authorizedWhenInUse:
            self?.locationClient.requestAuthorization()
          default:
            return
          }
        }
      )
      .share()

    authorizationStatus
      .map { $0 == .authorizedAlways }
      .receive(on: DispatchQueue.main)
      .assign(to: &$canStartActivity)

    authorizationStatus
      .map { authorizationStatus in
        switch authorizationStatus {
        case .authorizedAlways:
          return nil
        default:
          return "This application works only with full location access"
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$warningText)
  }

  func listenToLocationChanges() {
    let recordedLocations = locationClient.locations
      .scan([Location]()) { locations, location in
        var locations = locations
        locations.append(location)

        return locations
      }
      .map { [routingClient] recordedLocations in
        (
          locations: recordedLocations,
          distance: routingClient.routeDistance(recordedLocations)
        )
      }
      .share()

    recordedLocations
      .scan(
        (lastPhotoDistance: 0.0, lastPhotoLocation: Location?.none)
      ) { [distanceToPhotoTreshold] scan, recordedLocations in
        let isChangeOverPhotoTreshold = (recordedLocations.distance - scan.lastPhotoDistance) >= distanceToPhotoTreshold

        return isChangeOverPhotoTreshold
          ? (lastPhotoDistance: recordedLocations.distance, recordedLocations.locations.last)
          : scan
      }
      .removeDuplicates { $0.lastPhotoDistance == $1.lastPhotoDistance }
      .compactMap(\.lastPhotoLocation)
      .flatMap { [photosClient] lastPhotoLocation in
        photosClient.photoURLs(lastPhotoLocation)
          .replaceError(with: [])
      }
      .compactMap { [uuid] photoURLs -> Photo? in
        photoURLs
          .first
          .map { Photo(id: uuid().uuidString, url: $0) }
      }
      .scan([Photo]()) { photos, photo in
        [photo] + photos
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$photos)

    recordedLocations
      .map(\.distance)
      .map(Int.init)
      .map { "\($0)m" }
      .receive(on: DispatchQueue.main)
      .assign(to: &$title)
  }

  func startActivity() {
    isActivityInProgress = true
    locationClient.startUpdatingLocation()
  }

  func stopActivity() {
    isActivityInProgress = false
    locationClient.stopUpdatingLocation()
  }
}
