//
//  CreateAccountView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 10/11/20.
//

import SwiftUI

struct CreateAccountView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = CreateAccountViewModel()
    
    
    var pass: some View {
        AppTextField(leftIcon: Image(systemName: "lock.fill"),
                     rightIcon: Button(action: {
                        viewModel.securePassword.toggle()
                     }, label: {
                        Image(systemName: viewModel.securePassword ? "eye.fill" : "eye.slash.fill").foregroundColor(Color("redColor"))
                     }
                     ),
                     title: "Enter Password",
                     text: $viewModel.password,
                     isSecureEntry: viewModel.securePassword)
        
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                RedHeaderView(title: "Create Account", onBackTap: {
                    presentationMode.wrappedValue.dismiss()
                })
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        AppTextField(leftIcon: Image(systemName: "person.fill"),
                                     rightIcon: EmptyView(),
                                     title: "Enter Your Name",
                                     text: $viewModel.name)
                            .keyboardType(.namePhonePad)
                        AppTextField(leftIcon: Image(systemName: "envelope.fill"),
                                     rightIcon: EmptyView(),
                                     title: "Enter Email Id",
                                     text: $viewModel.emailID)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        PhoneNumberTextField(title: "Enter Mobile Number", text: $viewModel.phoneNumber, countryCode: $viewModel.countryCode)
                        pass
                        if let req = viewModel.otpReq {
                            NavigationLink(
                                destination: SignupVerifyOtpView(otpReq: req),
                                isActive: $viewModel.needOtpVerify) {EmptyView()}
                        }
                        
                        Button(action: viewModel.signupTapped,
                               label: {
                                Text("Continue")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 60)
                                    .background(Color("redColor")
                                                    .clipShape(Capsule()))
                                
                               })
                            .padding(24)
                            .padding(.bottom)
                    }
                }.padding()
            }
            if viewModel.loading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.black)
                    .background(Color.white.opacity(0.3))
            }
        }
        .alert(item: $viewModel.error, content: { (errString) -> Alert in
            Alert(title: Text(errString))
        })
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
            .previewDevice("iPhone 11")
    }
}


struct RedHeaderView: View {
    let title: String
    let onBackTap: () -> ()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: onBackTap, label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            })
            .padding(.bottom)
            
            Text(title)
                .font(.title)
                .foregroundColor(.white)
            Rectangle()
                .frame(width: 60, height: 4)
                .foregroundColor(.white)
        }
        .padding()
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(redbackground())
    }
    
    
    fileprivate func redbackground() -> some View {
        return GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height
                
                let tr = min(min(0, h/2), w/2)
                let tl = min(min(0, h/2), w/2)
                let bl = min(min(0, h/2), w/2)
                let br: CGFloat = 120
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(Color.red)
        }
    }
    
    
}
