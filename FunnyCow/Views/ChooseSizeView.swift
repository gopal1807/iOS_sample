//
//  ChooseSizeView.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 05/11/20.
//

import SwiftUI

struct ChooseSizeView: View {
    
    @StateObject private var viewModel: ChooseSizeViewModel
    
    init(catList: CatList, item: ItemList, currencySymbol: String) {
        _viewModel = StateObject(wrappedValue: ChooseSizeViewModel(category: catList, itemId: item.id, currencySymbol: currencySymbol))
    }
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .frame(width: 65, height: 4, alignment: .center)
                .foregroundColor(.accentColor)
                .padding(.top)
            ScrollView {
                VStack(alignment: .leading, spacing: 5.0) {
                    HStack {
                        Text(viewModel.item.name)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.trailing, 4.0)
                        if viewModel.item.specialOffer == nil {
                            PlusMinusCountView(minusTapped: viewModel.minusTapped,
                                               plusTapped: viewModel.plusTapped,
                                               count: viewModel.itemCount)
                        }
                    }
                    .padding([.horizontal, .bottom])
                    if !viewModel.availableSize.isEmpty {
                        sizeSelection()
                            .padding(.vertical)
                            .background(Color(#colorLiteral(red: 0.8940772414, green: 0.8980825543, blue: 0.9019982219, alpha: 1)))
                    }
                    ForEach(viewModel.item.addOnList) { item in
                        addOnView(item: item)
                    }
                    .padding(.horizontal)
                    
                    TextEditor(text: $viewModel.specialInstructions)
                        .foregroundColor(viewModel.specialInstructions == "Special Instructions" ? .gray : .primary)
                        .onTapGesture {
                            if viewModel.specialInstructions == "Special Instructions" {
                                viewModel.specialInstructions.removeAll()
                            }
                        }
                        .roundedCorner()
                        .padding(.horizontal)
                        .frame(height: 80)
                    Button(action: {
                        if viewModel.addItem() {
                            presentation.wrappedValue.dismiss()
                        }
                    }, label: {
                        HStack {
                            Text("Item Total \(viewModel.currencySymbol)\(viewModel.totalPrice.to2Decimal)")
                            Spacer()
                            Text("ADD ITEM").fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(minWidth: 10, maxWidth: 1000, idealHeight: 20)
                        .padding(12)
                        .background(Color.appAccent)
                        .cornerRadius(5)
                    })
                        .padding()
                }
                .padding(.vertical)
            }
        }
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
        .alert(item: $viewModel.error) { (errror) -> Alert in
            Alert(title: Text(errror))
        }
    }
    
    func addOnView(item: AddOnList) -> some View {
        return VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)
            Text(item.desc)
                .font(.subheadline)
                .fontWeight(.light)
            addOnOptions(addOn: item)
                .padding(.bottom)
        }
    }
    
    fileprivate func addOnOptions(addOn: AddOnList) -> some View{
        let selectedImage = addOn.dispType == "M" ? "checkmark.square.fill" : "largecircle.fill.circle"
        let unselectedImage = addOn.dispType == "M" ? "square" : "circle"
        return MyVGrid(views: addOn.addOnOptions.map({addOnOption(option: $0, addOn: addOn, selectedImage: selectedImage, unselectedImage: unselectedImage)}))
        
    }
    
    func addOnOption(option: AddOnOption, addOn: AddOnList, selectedImage: String, unselectedImage: String) -> some View {
        return VStack(alignment: .leading) {
            Button(action: {
                viewModel.selectAddon(addon: addOn, option: option)
            }) {
                HStack(alignment: .firstTextBaseline) {
                    
                    Image(systemName: option.isSelected ? selectedImage : unselectedImage)
                        .imageScale(.large)
                        .foregroundColor(option.isSelected ? Color.appAccent : Color.gray)
                    
                    Text(viewModel.getAddOnTitle(addOn: option))
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: 500, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(minWidth: 10, maxWidth: 500)
            if option.isSelected {
                HStack {
                    if let modify = addOn.addOnOptionModifier1, !modify.labels.isEmpty {
                        modifierPicker(addOn: addOn, option: option, modify: modify, modifiId: 1)
                    }
                    
                    if let modify = addOn.addOnOptionModifier2, !modify.labels.isEmpty {
                        modifierPicker(addOn: addOn, option: option, modify: modify, modifiId: 2)
                    }
                }
            }
        }
    }
    
    func modifierPicker(addOn: AddOnList, option: AddOnOption, modify: AddOnOptionModifier1, modifiId: Int) -> some View {
        Picker(selection: viewModel.getModifier(for: option, inList: addOn, modifiId: modifiId)) {
            ForEach(0..<modify.labels.count) { index in
                Text(modify.labels[index])
                    .tag(index)
            }
        } label: {
            HStack(spacing: 2) {
                Text(modify.labels[modifiId == 1 ? option.modifier1SelectedIndex : option.modifier2SelectedIndex])
                Image(systemName: "chevron.right")
            }
          
        }
        .pickerStyle(.menu)
        .accentColor(.white)
        .frame(minWidth: 20)
        .padding(5)
        .background(Color.appAccent)
        .frame(height: 30)
        .cornerRadius(5)
        .shadow(color: Color.gray.opacity(0.35), radius: 2, x: -2, y: 2)
        .shadow(color: Color.gray.opacity(0.5), radius: 2, x: -2, y: 2)
        .padding(.bottom, 5)
    }
    
    fileprivate func sizeSelection() -> some View {
        return VStack(alignment: .leading) {
            Text("Choose A Size")
                .font(.headline)
                .padding(.horizontal)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 2), spacing: 20) {
                ForEach(viewModel.availableSize) { size in
                    sizeView(size: size)
                }
            }
            .padding(.horizontal)
        }
    }
    
    func sizeView(size: ItemListSize) -> some View {
        return HStack {
            Button(action: {
                viewModel.selectedSize = size
            }, label: {
                let isSelected = size.id == viewModel.selectedSize?.id
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .imageScale(.large)
                    .foregroundColor(isSelected ? Color.appAccent : Color.black)
            })
            Text("\(size.name) \(viewModel.currencySymbol)\(size.price.to2Decimal)")
                .frame(maxWidth: UIScreen.main.bounds.width, alignment: .leading)
        }
        .frame(minWidth: 10, maxWidth: 500)
        
    }
    
}


struct PlusMinusCountView: View {
    
    let minusTapped: () -> ()
    let plusTapped: () -> ()
    let count: Int
    
    func btn(action: @escaping () -> (), name: String) -> some View {
        Button(action: action, label: {
            Image(systemName: name)
                .font(.system(size: 22))
                .foregroundColor(Color.appAccent)
        })
    }
    
    var body: some View {
        HStack(spacing: 3.0) {
            btn(action: minusTapped, name: "minus.circle.fill")
            Text("\(count)")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4.0)
            btn(action: plusTapped, name: "plus.circle.fill")
        }
        .padding(4.0)
        .overlay(
            Capsule().strokeBorder(Color.gray)
        )
    }
}


struct MyVGrid<Content: View>: View {
    let views: [Content]
    
    var body: some View {
        let rows: Int = Int((Double(views.count)/2.0).rounded(.up))
        let numberOfRows: Int = max(1, rows)
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(0 ..< numberOfRows) { row in
                let rangeStart = 2*row
                let rangeEnd = min(views.count, rangeStart + 2)
                HStack(alignment: .top, spacing: 4) {
                    ForEach(rangeStart ..< rangeEnd) { index in
                        views[index]
                            .frame(minWidth: UIScreen.main.bounds.width/2 - 50, alignment: .leading)
                    }
                }
            }
        }
        .padding(.top, 5)
    }
    
}
