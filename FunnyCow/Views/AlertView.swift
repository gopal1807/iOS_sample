//
//  AlertView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 02/12/20.
//

import SwiftUI

struct AlertView: View {
    let alert: AlertTitle
    let showAnimation: Bool
    let okPressed: () -> Void
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack {
            
            HStack(alignment: .top) {
                if showAnimation {
                LottieView(name: "bike")
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .padding(.top)
                }
                
                Button(action: {okPressed()}, label: {
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
            }
            
            
            Text(alert.title)
                .font(.title3)
                .foregroundColor(Color.appAccent)
                .padding(.horizontal)
            Text(alert.subTitle)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Button(action: {
                okPressed()
            }, label: {
                Text("OK")
                    .foregroundColor(.white)
                    .padding(8)
                    .padding(.horizontal, 40)
                    .background(Color.appAccent.clipShape(Capsule()))
                    .addNeumoShadow(shadowRadius: 5)
            }).padding(.bottom, 8)
            
        }
        .padding(5)
        .padding(.vertical, 4)
        .background(Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 16)))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1).edgesIgnoringSafeArea(.all))
    }
}

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView(alert: AlertTitle(title: "Davis Montas Popayes", subTitle: "Sorry, we are currently closed."), showAnimation: true, okPressed: {})
            .previewDevice("iPhone 11")
    }
}

struct AlertTitle: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
}
