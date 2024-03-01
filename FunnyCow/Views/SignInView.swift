//
//  SignInView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 10/11/20.
//

import SwiftUI

struct SignInView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = SignInViewModel()
    @EnvironmentObject var tabbarViewModel: TabbarSelection
    
    func getMobileNumber() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("calling mobile number \(self.tabbarViewModel.getMobileNumber)")
            self.tabbarViewModel.getMobileNumber = true
        }
    }
    
    var body: some View {
        viewModel.getMobileNumber = self.getMobileNumber
        return Navigation(
            ZStack {
                alerts()
                ScrollView {
                    VStack {
                        VStack(alignment: .leading) {
                            signINView()
                            NavigationLink(destination: CreateAccountView()) {
                                HStack {
                                    Text("Create your Account")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.title2)
                                .foregroundColor(Color("redColor"))
                                .padding(.bottom)
                            }
                            .padding(30.0)
                        }
                        .background(
                            Color(#colorLiteral(red: 0.9371904731, green: 0.9254908562, blue: 0.9620193839, alpha: 1))
                                .cornerRadius(radius: 250, corners: [.bottomRight])
                        )
                        Spacer(minLength: 8)
                        socialLoginView()
                    }
                }
                if viewModel.loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.2))
                }
            }
                .navigationBarHidden(true)
        )
        .environment(\.rootPresentationMode, $viewModel.forgetPassTapped)
        .onAppear {
            viewModel.cancellable = viewModel.$popView.sink(receiveValue: { (pop) in
                if pop {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
        
    }
    
    func alerts() -> some View {
        return VStack {
            Text("")
                .alert(item: $viewModel.error) { (error) -> Alert in
                    Alert(title: Text(error))
                }
            
            NavigationLink(isActive: $viewModel.forgetPassTapped) {
                ForgotPassView()
            } label: {
                EmptyView()
            }
        }
    }
    
    fileprivate func socialLoginView() -> some View {
        HStack {
            Text("New & Old user\nplease login with").foregroundColor(Color("redColor"))
            Spacer()
            Button(action: viewModel.appleLoginTapped, label: {
                Image("appleLogin")
                    .resizable()
                    .frame(width: 45, height: 45)
                
            })

            Button(action: viewModel.gmalLoginTapped, label: {
                Image("google")
                    .resizable()
                    .frame(width: 45, height: 45)
                    .foregroundColor(Color("redColor"))
            })
        }.padding()
    }
    fileprivate func signINView() -> some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("Sign")
                    .bold()
                    .underline()
                Text("In").bold()
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "multiply.circle")
                })
            }
            .font(.title2)
            .padding(.bottom, 25)
            AppTextField(leftIcon: Image(systemName: "person.fill"),
                         rightIcon: EmptyView(),
                         title: "Enter Email ID",
                         text: $viewModel.emailID,
                         placeholderColor: Color.white)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
            
            AppTextField(leftIcon: Image(systemName: "lock.fill"),
                         rightIcon:
                            Button(action: {
                                viewModel.isPassSecure.toggle()
                            }, label: {
                                Image(systemName: viewModel.isPassSecure ? "eye.fill" : "eye.slash.fill")
                            }),
                         title: "Enter Password",
                         text:  $viewModel.password,
                         isSecureEntry: viewModel.isPassSecure,
                         placeholderColor: Color.white)
                .padding()
            Button(action: {
                viewModel.forgetPassTapped = true
            }) {
                Text("Forgot Password?")
                    .font(.title3)
                    .underline()
            }
            .padding([.leading, .bottom])
            
            Button(action: {
                viewModel.signIntapped()
            }, label: {
                Text("Sign In")
                    .font(.title3)
                    .foregroundColor(.black)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 60)
                    .background(Color.white.clipShape(Capsule()))
            })
            .padding(24)
            .padding(.bottom)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            Color("redColor")
                .cornerRadius(radius: 250, corners: [.bottomRight])
        )
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .previewDevice("iPhone 11")
    }
}


struct RootPresentationModeKey: EnvironmentKey {
//    static var defaultValue: Value
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}

typealias RootPresentationMode = Bool

extension RootPresentationMode {
    
    public mutating func dismiss() {
        self.toggle()
    }
}
