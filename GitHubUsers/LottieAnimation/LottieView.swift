//
//  LottieView.swift
//  GitHubUsers
//
//  Created by Cathal Farrell on 12/06/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {

    @Binding var playAnimation: Bool

    var name: String!

    var animationView = AnimationView()

    class Coordinator: NSObject {
        var parent: LottieView

        init(_ animationView: LottieView) {
            self.parent = animationView
            super.init()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        print("View Updated")
        animationView.play()
    }

}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(playAnimation: .constant(true))
    }
}
