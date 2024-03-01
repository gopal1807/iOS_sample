//
//  ExtraSignUpDataView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 22/12/20.
//

import SwiftUI

struct ExtraSignUpDataView: View {
    //    @Environment(\.presentationMode) var presentation
    @StateObject var viewModel = ExtraSignupViewModel()
    var userData: UserModel? {
        UserDefaultsController.shared.userModel
    }
    @EnvironmentObject var tabbarViewModel: TabbarSelection
    
    func dismiss() {
        self.tabbarViewModel.getMobileNumber = false
    }
    
    var body: some View {
        viewModel.dismiss = self.dismiss
        return ZStack {
            VStack {
                
                //            Button(action: {
                //                presentation.wrappedValue.dismiss()
                //            }, label: {
                //                Image(systemName: "x.circle.fill")
                //                    .font(.title)
                //                    .foregroundColor(.white)
                //                    .background(
                //                        Color("redColor")
                //                            .clipShape(Circle())
                //                            .padding(5)
                //                    )
                //                    .addNeumoShadow(shadowRadius: 5)
                //            })
                
                LottieView(name: "welcome")
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: 150)
                
                Text("Hello, \(userData?.fullName ?? "")!!")
                    .font(.title2)
                    .foregroundColor(Color.appAccent)
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                
                Text("Please enter below details")
                    .foregroundColor(Color.appAccent)
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
                
                AppTextField(leftIcon: Image(systemName: "envelope.fill")
                                .foregroundColor(Color.appAccent),
                             rightIcon: EmptyView(),
                             text: Binding<String>.constant(userData?.email ?? ""))
                    .disabled(true)
                    .padding(.vertical)
                
                PhoneNumberTextField(title: "Enter Mobile Number", text: $viewModel.mobileNumber, countryCode: $viewModel.countryCode)
                    .padding(.bottom)
                
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
                Text("")
                    .alert(item: $viewModel.error) { (str) -> Alert in
                        Alert(title: Text(str))
                    }
                
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}


