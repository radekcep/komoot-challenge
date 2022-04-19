#if DEBUG
//
//  DashboardViewModel+stub.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Foundation

extension DashboardViewModel {
  static func stub(
    title: String?,
    photos: [Photo],
    isActivityInProgress: Bool
  ) -> DashboardViewModel {
    let viewModel = DashboardViewModel()
    viewModel.title = title
    viewModel.photos = photos
    viewModel.isActivityInProgress = isActivityInProgress

    return viewModel
  }
}
#endif
