//
//  DashboardViewModel.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Foundation

class DashboardViewModel: ObservableObject {
  private let locationClient: LocationClient

  @Published var title: String?
  @Published var photos: [Photo] = []
  @Published var isActivityInProgress: Bool = false

  init(
    locationClient: LocationClient
  ) {
    self.locationClient = locationClient
  }

  func startActivity() {}
  func stopActivity() {}
}
