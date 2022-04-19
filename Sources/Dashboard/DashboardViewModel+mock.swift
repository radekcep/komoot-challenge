#if DEBUG
//
//  DashboardViewModel+mock.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Foundation

extension DashboardViewModel {
  static func mock(
    title: String?,
    warningText: String?,
    photos: [Photo],
    canStartActivity: Bool,
    isActivityInProgress: Bool
  ) -> DashboardViewModel {
    let viewModel = DashboardViewModel(
      locationClient: .stub,
      photosClient: .stub,
      routingClient: .stub
    )
    viewModel.title = title
    viewModel.warningText = warningText
    viewModel.photos = photos
    viewModel.canStartActivity = canStartActivity
    viewModel.isActivityInProgress = isActivityInProgress

    return viewModel
  }
}
#endif
