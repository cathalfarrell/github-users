//
//  UserDetailView.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//
//  swiftlint:disable multiple_closures_with_trailing_closure

import SwiftUI
import struct Kingfisher.KFImage

struct UserDetailView: View {

    @State var user: User
    @State var errorString: String = ""
    @State var playAnimation = false

    var body: some View {
        ZStack {

            VStack {
                HStack(spacing: 0) {
                    Spacer()
                    KFImage(URL(string: user.avatarUrl))
                        .placeholder({
                            Image("placeholderImage")
                        })
                    .resizable()
                    .frame(width: 128, height: 128)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                     Spacer()
                }
                Form {
                    //Error View - If any errors
                    if !errorString.isEmpty {
                        VStack(alignment: .center) {
                            Text(errorString)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0,
                                       maxHeight: .infinity, alignment: .topLeading)
                                .padding(16)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .font(.body)
                                .multilineTextAlignment(.center)

                            Button("Try Again") {
                                print("Try network again")
                                self.loadUser()
                            }
                            .padding()
                        }
                        .padding([.top, .bottom], 16)
                    }
                    Section {
                        HStack {
                            Text("Username:")
                            Spacer()
                            Text("\(user.login)")
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Name:")
                            Spacer()
                            Text("\(user.name)")
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Location:")
                            Spacer()
                            Text("\(user.location)")
                                .font(.subheadline)
                        }
                    }
                    Section {
                        HStack {
                            Text("Public Repositories:")
                            Spacer()
                            Text("\(user.publicRepos)")
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Public Gists:")
                            Spacer()
                            Text("\(user.publicGists)")
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Followers:")
                            Spacer()
                            Text("\(user.followers)")
                                .font(.subheadline)
                        }
                        HStack {
                            Text("Following:")
                            Spacer()
                            Text("\(user.following)")
                                .font(.subheadline)
                        }
                    }
                }
            }

            if playAnimation {
                LottieView(playAnimation: $playAnimation, name: "18357-spinner-dots")
                .frame(width: 100, height: 100)
            }
        }
        .navigationBarTitle("User Details", displayMode: .inline)
        .onAppear(perform: loadUser)
    }

   // MARK: - Get Users

    fileprivate func loadUser() {

        print("Loading user: \(user.login)")
        self.errorString = ""

        self.playAnimation.toggle()

        //Load Users - this method returns on Main Thread
        Users.shared.downloadUserDetailFromNetwork(with: user.login, success: { (user) in
            self.user = user
            self.playAnimation.toggle()
        }) { (errorString) in
            self.errorString = errorString
            self.playAnimation.toggle()
        }

        //Get user from Persistency Manager later if time
    }
}

struct UserDetailView_Previews: PreviewProvider {

    static let testError = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, " +
                                "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

    static var previews: some View {
        NavigationView {
            UserDetailView(user: User.sampleUser(), errorString: testError)
        }
    }
}
