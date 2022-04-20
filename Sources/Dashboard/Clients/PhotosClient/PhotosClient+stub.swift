#if DEBUG
//
//  PhotosClient+stub.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

extension PhotosClient {
  static var stub: Self {
    .init(
      photoURLs: { _ in Empty().eraseToAnyPublisher() }
    )
  }
}

#endif
