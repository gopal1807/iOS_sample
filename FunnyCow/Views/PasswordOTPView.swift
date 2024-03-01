//
//  PasswordOTPView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 16/11/20.
//

import SwiftUI

struct PasswordOTPView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.rootPresentationMode) var rootPresentationMode
    
    init(otpRequest: ResetPassRequest) {
        _viewModel = StateObject(wrappedValue: PasswordOtpViewModel(otpRequest))
    }
    
    @StateObject var viewModel: PasswordOtpViewModel
    
    var body: some View {
        ZStack {
            VStack {
                RedHeaderView(title: "Verify OTP") {
                    presentationMode.wrappedValue.dismiss()
                }
                Text("Verification code sent to your Email Address")
                Label(viewModel.otpRequest.data.username, systemImage: "envelope.fill")
                ZStack {
                    HStack {
                        ForEach(0 ..< 4) { item in
                            Text(getChar(at: item))
                                .frame(width: 40.0, height: 40.0)
                                .roundedCorner(color: Color("redColor"))
                        }
                    }
                    .padding()
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
                            viewModel.resendOtp()
                        }
                    }
                    .foregroundColor(viewModel.timerCount == 0 ? Color.appAccent : .gray)
                }
                
                AppTextField(leftIcon: Image(systemName: "lock.fill"), rightIcon: Button(action: {
                    viewModel.secureTextField.toggle()
                }, label: {
                    Image(systemName: viewModel.secureTextField ? "eye.fill" : "eye.slash.fill")
                }), title: "Enter new password", text: $viewModel.newPassword, isSecureEntry: viewModel.secureTextField)
                .disableAutocorrection(true)
                .padding(.horizontal)
                .padding(.vertical, 5)
                
                
                Button(action: viewModel.verifyOtp, label: {
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
                alerts
                Spacer()
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        
    }
    
    private var alerts: some View {
        VStack {
            Text("")
                .alert(item: $viewModel.error) { (errString) -> Alert in
                    Alert(title: Text(errString))
                }
            Text("")
                .alert(isPresented: $viewModel.isPassReset) { () -> Alert in
                    Alert(title: Text("Password was successfully reset\nPlease login with your new password!"), message: nil, dismissButton: .default(Text("OK"), action: {
                        rootPresentationMode.wrappedValue.dismiss()
                    }))
                }
        }
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
        if viewModel.otp.count > 4 {
            viewModel.otp = String(viewModel.otp.prefix(4))
            submitPin()
        }
    }
    
}
//
//struct PasswordOTPView_Previews: PreviewProvider {
//    static var previews: some View {
//        PasswordOTPView()
//    }
//}
