//
//  EmptyProfileView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 17/11/20.
//

import SwiftUI

struct EmptyProfileView: View {
    
    @StateObject var viewModel = EmptyProfileViewModel()
    
      var body: some View {
        VStack {
            Image("userNotLogIn")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.appAccent)
            Button(action: {
                viewModel.showLogin.toggle()
            }, label: {
                Text("SIGN IN")
                    .foregroundColor(.white)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .padding()
                    .background(Color.appGreen
                                    .cornerRadius(8.0))
                    .padding()
                
            })
        }
        .sheet(isPresented: $viewModel.showLogin, content: {
            SignInView()
        })
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct EmptyProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyProfileView()
            .previewDevice("iPhone 11")
    }
}

class EmptyProfileViewModel: ObservableObject {
    @Published var showLogin = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(dismissLogin), name: .dismissLoginView, object: nil)
    }
    @objc func dismissLogin() {
        self.showLogin = false
    }
}
