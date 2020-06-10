//
//  UserDetailView.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI
import struct Kingfisher.KFImage

struct UserDetailView: View {

    @State var user: User
    @State var errorString: String = ""

    var body: some View {
        VStack {
            HStack(spacing: 0){
                Spacer()
                KFImage(URL(string: user.avatarUrl))
                .resizable()
                .frame(width: 128, height: 128)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
                 Spacer()
            }
            Form {
                Section() {
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
                }
            }
        }

        .navigationBarTitle("User Details", displayMode: .inline)
        .onAppear(perform: loadUser)
    }

   // MARK:- Get Users

    fileprivate func loadUser() {

        print("Loading user: \(user.login)")

        //Load Users - this method returns on Main Thread
        Users.shared.downloadUserDetailFromNetwork(with: user.login, success: { (user) in
            self.user = user
        }) { (errorString) in
            self.errorString = errorString
        }

        //Get user from Persistency Manager later if time
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserDetailView(user: User.sampleUser())
        }
    }
}
