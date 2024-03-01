//
//  Testing.swift
//  Pockets
//
//  Created by Gopal Krishan on 04/02/21.
//

import SwiftUI

struct Testing: View {
    var body: some View {
        HStack(spacing: 10) {
            Image("locationImg")
                .resizable()
                .foregroundColor(Color.appAccent)
                .frame(width: 40, height: 40)
                .padding(12)
                .background(Color(#colorLiteral(red: 0.9436354041, green: 0.9436575174, blue: 0.9436456561, alpha: 1)))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 2) {
                Text("Pockets 3001 N. Lincoln")
            }
            .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
        }
    
       
    }
}

struct Testing_Previews: PreviewProvider {
    static var previews: some View {
        Testing()
    }
}
