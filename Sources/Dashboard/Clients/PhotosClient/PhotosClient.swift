//
//  PhotosClient.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

struct PhotosClient {
  let photoURLs: (Location) -> AnyPublisher<[URL], Error>
}

extension PhotosClient {
  enum Error: Swift.Error {
    case invalidURLComponents(URLComponents)
    case urlError(URLError)
    case decodingError(Swift.Error)
  }
}
