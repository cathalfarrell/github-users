//
//  UserDetailView.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 10/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import SwiftUI

struct UserDetailView: View {
    @State var user: User

    var body: some View {
        Form {
            Section(header: Text("User Details")) {
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
            .font(.headline)
        }
        .navigationBarTitle("User Detail")
        .onAppear(perform: loadUser)
    }

    func loadUser() {
        print("Loading User")
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserDetailView(user: User.sampleUser())
        }
    }
}
