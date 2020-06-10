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

        .navigationBarTitle("User Details")
        .onAppear(perform: loadUser)
    }

    func loadUser() {
        print("Loading User...")
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserDetailView(user: User.sampleUser())
        }
    }
}
