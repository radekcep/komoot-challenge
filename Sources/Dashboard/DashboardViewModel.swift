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

  @Published var title: String?
  @Published var photos: [Photo] = []
  @Published var isActivityInProgress: Bool = false

  init(
    locationClient: LocationClient,
    photosClient: PhotosClient
  ) {
    self.locationClient = locationClient
    self.photosClient = photosClient
  }

  func startActivity() {}
  func stopActivity() {}
}
