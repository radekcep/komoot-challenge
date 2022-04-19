//
//  DashboardViewModel.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Foundation

class DashboardViewModel: ObservableObject {
  @Published var title: String?
  @Published var photos: [Photo]
  @Published var isActivityInProgress: Bool

  init() {
    title = nil
    photos = []
    isActivityInProgress = false
  }

  func startActivity() {}
  func stopActivity() {}
}
