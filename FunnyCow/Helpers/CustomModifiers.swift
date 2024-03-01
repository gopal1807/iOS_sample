//
//  CustomModifiers.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 05/11/20.
//

import SwiftUI

struct ImageSize: ViewModifier {
    let size: CGFloat
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .frame(width: size)
            .background(Color(#colorLiteral(red: 0.9436354041, green: 0.9436575174, blue: 0.9436456561, alpha: 1)))
            .cornerRadius(5)
    }
}

struct AddNeumoShadow: ViewModifier {
    let shadowRadius: CGFloat
    func body(content: Content) -> some View {
        let blackRadius = max(0, shadowRadius - 2)
        return content
            .shadow(color: Color.black.opacity(0.35), radius: blackRadius, x: blackRadius, y: blackRadius)
            .shadow(color: .white, radius: shadowRadius, x: -shadowRadius, y: -shadowRadius)
    }
    
    
}

struct RoundedBorder: ViewModifier {
    var radius: CGFloat
    var color: Color
    var padding: CGFloat
    
    func body(content: Content) -> some View {
        content.padding(padding).overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(color))
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    struct CornerRadiusShape: Shape {

        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

struct AppTextField<T, D: View>: View where T: View {
    let leftIcon: T
    let rightIcon: D
    let title: String
    let text: Binding<String>
    let isSecureEntry: Bool
    let textColor: Color
    
    init(leftIcon: T, rightIcon: D, title: String = "", text: Binding<String>, isSecureEntry: Bool = false, placeholderColor: Color = Color(#colorLiteral(red: 0.47882092, green: 0.47882092, blue: 0.47882092, alpha: 1))) {
        self.isSecureEntry = isSecureEntry
        self.text = text
        self.title = title
        self.rightIcon = rightIcon 
        self.leftIcon = leftIcon
        self.textColor = placeholderColor
        
    }
    
    var body: some View {
        VStack {
            HStack {
                leftIcon
                    .font(.system(size: 25))
                ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
                    if text.wrappedValue.isEmpty {
                        Text(title).foregroundColor(textColor.opacity(0.8))
                    }
                    if isSecureEntry {
                        SecureField(title, text: text)
                    } else {
                        TextField(title, text: text)
                    }
                }
                .foregroundColor(textColor)
                rightIcon
            }
            .padding(.bottom, 5)
            Rectangle().frame(height: 1).foregroundColor(textColor)
        }
    }
}


struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    let placeHolder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.resignFirstResponder()
        }
        
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = placeHolder
        searchBar.showsCancelButton = true
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct Navigation<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: some View {
        NavigationView {
            build()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
