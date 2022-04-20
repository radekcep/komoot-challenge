//
//  PhotosClient+live.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import Combine
import Foundation

extension PhotosClient {
  static var live: Self {
    let apiKey = "FLICKR_TOKEN"

    return .init { location in
      var urlComponents = URLComponents()
      urlComponents.scheme = "https"
      urlComponents.host = "www.flickr.com"
      urlComponents.path = "/services/rest/"
      urlComponents.queryItems = [
        .init(name: "api_key", value: apiKey),
        .init(name: "method", value: "flickr.photos.search"),
        .init(name: "format", value: "json"),
        .init(name: "nojsoncallback", value: "1"),
        .init(name: "lat", value: String(location.latitude)),
        .init(name: "lon", value: String(location.longitude))
      ]

      guard let url = urlComponents.url else {
        return Fail(error: .invalidURLComponents(urlComponents))
          .eraseToAnyPublisher()
      }

      return URLSession.shared
        .dataTaskPublisher(for: url)
        .mapError(PhotosClient.Error.urlError)
        .map(\.data)
        .decode(type: FlickrPhotos.self, decoder: JSONDecoder())
        .mapError(PhotosClient.Error.decodingError)
        .map { flickrPhotos in
          flickrPhotos.photos.photo
            .map { "https://farm\($0.farm).staticflickr.com/\($0.server)/\($0.id)_\($0.secret).jpg" }
            .compactMap(URL.init)
        }
        .eraseToAnyPublisher()
    }
  }
}

extension PhotosClient {
  struct FlickrPhotos: Decodable {
    var photos: FlickrPhotosPage
  }

  struct FlickrPhotosPage: Decodable {
    let photo: [FlickrPhoto]
  }

  struct FlickrPhoto: Decodable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
  }
}
