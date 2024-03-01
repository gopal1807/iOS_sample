//
//  MergeAccountView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 22/12/20.
//

import SwiftUI

struct MergeAccountView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var viewModel: MergeAccountViewModel
    
    init(data: Customerfbdata, user: UserModel) {
        _viewModel = StateObject(wrappedValue: MergeAccountViewModel(data, user: user))
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .trailing) {
                
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "x.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .background(
                            Color("redColor")
                                .clipShape(Circle())
                                .padding(5)
                        )
                        .addNeumoShadow(shadowRadius: 5)
                })
                
                LottieView(name: "welcome")
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 150)
                
                Text("Hello, \(viewModel.customerData.fName ?? "")!!")
                    .font(.title2)
                    .foregroundColor(Color.appAccent)
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                
                Text("Please enter your existing online ordering password to associate this social login with the existing online ordering account.")
                    .foregroundColor(Color.appAccent)
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                
                AppTextField(leftIcon: Image(systemName: "lock.fill"),
                             rightIcon:
                                Button(action: {
                                    viewModel.isPassSecure.toggle()
                                }, label: {
                                    Image(systemName: viewModel.isPassSecure ? "eye.fill" : "eye.slash.fill")
                                }),
                             title: "Enter Password",
                             text:  $viewModel.password,
                             isSecureEntry: true)
                    .padding(.vertical)
                
                Button(action: viewModel.submitTapped, label: {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding(8)
                        .padding(.horizontal, 20)
                        .background(Color.appAccent.clipShape(Capsule()))
                        .addNeumoShadow(shadowRadius: 5)
                })
                .padding(.bottom, 8)
                Spacer()
            }
            .padding()
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .alert(item: $viewModel.error) { (str) -> Alert in
            Alert(title: Text(str))
        }
    }
}
