//
//  ForgotPassView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 11/11/20.
//

import SwiftUI

struct ForgotPassView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = ForgotPasswordViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                RedHeaderView(title: "Forgot Password", onBackTap: {
                    presentationMode.wrappedValue.dismiss()
                })
//                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        Text("We just need your registered Email ID to send you OTP for reset password")
                            .font(.callout)
                        
                        AppTextField(leftIcon: Image(systemName: "envelope.fill"), rightIcon: EmptyView(), title: "Enter Email Id", text: $viewModel.emailId)
                            .padding(.vertical, 50)
                        
                        
                        Button(action: viewModel.sendOtpTapped, label: {
                            Text("SEND OTP")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 60)
                                .background(Color("redColor")
                                                .clipShape(Capsule()))
                            
                        })
                        .padding(24)
                        .padding(.bottom)
                   
                        if let req = viewModel.otpRequest {
                            NavigationLink(destination: PasswordOTPView(otpRequest: req), isActive: $viewModel.pushToOtp) {  EmptyView() }
                        }
                    }
                    .padding()
//                }.padding()
                Spacer()
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .alert(item: $viewModel.error, content: { (errString) -> Alert in
            Alert(title: Text(errString))
        })
    }
}

struct ForgotPassView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPassView()
            .previewDevice("iPhone 11")
    }
}
