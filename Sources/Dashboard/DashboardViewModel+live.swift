//
//  DashboardViewModel+live.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Foundation

extension DashboardViewModel {
  static var live: DashboardViewModel {
    .init(
      locationClient: .live,
      photosClient: .live
    )
  }
}
