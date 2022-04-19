//
//  DashboardViewModel.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

class DashboardViewModel: ObservableObject {
  private let locationClient: LocationClient
  private let photosClient: PhotosClient
  private let routingClient: RoutingClient

  @Published var title: String?
  @Published var warningText: String?
  @Published var photos: [Photo] = []
  @Published var canStartActivity: Bool = false
  @Published var isActivityInProgress: Bool = false

  private var cancellables: Set<AnyCancellable> = []

  init(
    locationClient: LocationClient,
    photosClient: PhotosClient,
    routingClient: RoutingClient
  ) {
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
      .assign(to: &$canStartActivity)

    authorizationStatus
      .compactMap { authorizationStatus in
        switch authorizationStatus {
        case .authorizedAlways:
          return nil
        default:
          return "This application works only with full location access"
        }
      }
      .assign(to: &$warningText)
  }

  func startActivity() {
    locationClient.startUpdatingLocation()
  }

  func stopActivity() {
    locationClient.stopUpdatingLocation()
  }
}
