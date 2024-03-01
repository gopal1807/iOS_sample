//
//  EmptyCartView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 17/11/20.
//

import SwiftUI

struct EmptyCartView: View {
    var body: some View {
        VStack {
            Image("emptyCart")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.appAccent)
            Text("Add something to make me happy :)")
                .font(.body)
                .foregroundColor(.gray)
        }
        .padding()
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct EmptyCartView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyCartView()
            .previewDevice("iPhone 11")
    }
}
