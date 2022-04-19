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
    photos: [Photo],
    isActivityInProgress: Bool
  ) -> DashboardViewModel {
    let viewModel = DashboardViewModel(
      locationClient: .stub,
      photosClient: .stub,
      routingClient: .stub
    )
    viewModel.title = title
    viewModel.photos = photos
    viewModel.isActivityInProgress = isActivityInProgress

    return viewModel
  }
}
#endif
