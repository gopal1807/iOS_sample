//
//  LottieView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 26/11/20.
//

import SwiftUI
import Lottie


struct LottieView: UIViewRepresentable {

    var name: String

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let animationView = AnimationView()
        animationView.backgroundColor = .clear
        animationView.animation = Animation.named(name)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
    }
}
