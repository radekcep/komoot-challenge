//
//  DashboardViewModel.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Foundation

class DashboardViewModel: ObservableObject {
  private let locationClient: LocationClient
  private let photosClient: PhotosClient
  private let routingClient: RoutingClient

  @Published var title: String?
  @Published var photos: [Photo] = []
  @Published var isActivityInProgress: Bool = false

  init(
    locationClient: LocationClient,
    photosClient: PhotosClient,
    routingClient: RoutingClient
  ) {
    self.locationClient = locationClient
    self.photosClient = photosClient
    self.routingClient = routingClient
  }

  func startActivity() {}
  func stopActivity() {}
}
