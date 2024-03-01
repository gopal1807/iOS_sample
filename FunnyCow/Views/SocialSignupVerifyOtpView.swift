//
//  SocialSignupVerifyOtpView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 23/12/20.
//


import SwiftUI

struct SocialSignupOtpVerifyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    init(otpReq: DoGoogleLoginRequest) {
        _viewModel = StateObject(wrappedValue: SocialSignupVerifyOtpViewModel(otpReq))
    }
    
    @StateObject var viewModel: SocialSignupVerifyOtpViewModel
    
    var body: some View {
        ZStack {
            VStack {
                
                RedHeaderView(title: "Verify OTP") {
                    presentationMode.wrappedValue.dismiss()
                }
                Text("Verification code sent to your Email Address")
                Label(viewModel.otpReq.data.customerFBData.fbemail ?? "", systemImage: "envelope.fill")
                ZStack {
                    HStack {
                        ForEach(0 ..< 4) { item in
                            Text(getChar(at: item))
                                .frame(width: 40.0, height: 40.0)
                                .roundedCorner(color: Color("redColor"))
                        }
                    }.padding()
                    
                    backgroundField
                }
                
                
                Text("Left \(String(format: "%02d:%02d", (viewModel.timerCount/60), (viewModel.timerCount%60))) second")
                    .foregroundColor(Color("redColor"))
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .overlay(
                        Capsule().strokeBorder(Color("redColor"))
                    ).padding()
                
                HStack {
                    Text("Didn't receive the code?")
                    Button("Resend") {
                        if viewModel.timerCount == 0 {
//                            viewModel.resendOtp()
                        }
                    }
                    .foregroundColor(viewModel.timerCount == 0 ? Color.appAccent : .gray)
                }
                Button(action: viewModel.verifyOtp,
                       label: {
                        Text("VERIFY OTP")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 60)
                            .background(Color("redColor")
                                    .clipShape(Capsule()))
                        
                       })
                    .padding(24)
                    .padding(.bottom)
                Spacer()
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .alert(item: $viewModel.error, content: { (errString) -> Alert in
            Alert(title: Text(errString))
        })
    }

    private func getChar(at offset: Int) -> String {
        if !viewModel.otp.isEmpty, offset <= (self.viewModel.otp.count - 1) {
            let index = viewModel.otp.index(viewModel.otp.startIndex, offsetBy: offset)
            let char = viewModel.otp[index]
            return String(char)
        }
        return ""
    }
    private var backgroundField: some View {
        let boundPin = Binding<String>(get: { self.viewModel.otp }, set: { newValue in
            self.viewModel.otp = newValue
            self.submitPin()
        })
        
        return TextField("", text: boundPin, onCommit: submitPin)
            .accentColor(.clear)
            .foregroundColor(.clear)
            .keyboardType(.numberPad)
        
    }
    
    private func submitPin() {
        guard !viewModel.otp.isEmpty else {
            return
        }
        
        if viewModel.otp.count == 4 {
            viewModel.verifyOtp()
        }

        if viewModel.otp.count > 4 {
            viewModel.otp = String(viewModel.otp.prefix(4))
            submitPin()
        }
    }
    
        
}
