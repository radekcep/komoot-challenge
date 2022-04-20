//
//  DashboardView.swift
//  KomootChallenge
//
//  Created by Radek Čep on 19.04.2022.
//

import SwiftUI

struct DashboardView: View {
  @ObservedObject var viewModel: DashboardViewModel

  var body: some View {
    NavigationView {
      VStack {
        viewModel.warningText
          .map(Text.init)

        List(viewModel.photos) { photo in
          AsyncImage(url: photo.url) { image in
            image
              .resizable()
              .scaledToFill()
              .frame(height: 240)
              .clipped()
          } placeholder: {
            GeometryReader { geometry in
              ProgressView()
                .frame(
                  width: geometry.size.width,
                  height: geometry.size.height,
                  alignment: .center
                )
            }
          }
          .frame(height: 240)
          .listSectionSeparator(.hidden)
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          if viewModel.canStartActivity {
            Button {
              viewModel.isActivityInProgress
                ? viewModel.stopActivity()
                : viewModel.startActivity()
            } label: {
              viewModel.isActivityInProgress
                ? Text("Stop")
                : Text("Start")
            }
          }
        }
      }
      .navigationTitle(viewModel.title ?? "")
      .navigationBarTitleDisplayMode(.inline)
      .listStyle(.plain)
      .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
    .navigationViewStyle(.stack)
    .onAppear(perform: viewModel.requestPermissions)
    .onAppear(perform: viewModel.listenToLocationChanges)
  }
}

struct DashboardView_Previews: PreviewProvider {
  static var previews: some View {
    DashboardView(
      viewModel: .mock(
        title: "450m",
        warningText: "Placeholder warning",
        photos: [
          .init(
            id: UUID().uuidString,
            url: .init(string: "https://cdn.wallpapersafari.com/69/4/j0JeYp.jpg")!
          ),
          .init(
            id: UUID().uuidString,
            url: .init(string: "https://cdn.wallpapersafari.com/69/4/j0JeYp.jpg")!
          ),
          .init(
            id: UUID().uuidString,
            url: .init(string: "https://cdn.wallpapersafari.com/69/4/j0JeYp.jpg")!
          ),
          .init(
            id: UUID().uuidString,
            url: .init(string: "https://cdn.wallpapersafari.com/69/4/j0JeYp.jpg")!
          )
        ],
        canStartActivity: true,
        isActivityInProgress: true
      )
    )
  }
}
