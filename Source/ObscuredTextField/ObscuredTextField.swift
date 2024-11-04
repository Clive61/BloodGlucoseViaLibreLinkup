//
//  ObscureTextField.swift
//  ObscureTextField
//
//  Created by Clive on 03/11/2024.
//
import SwiftUI

struct ObscuredTextField: View {
    
    @Binding private var text: String
    @State private var isObscured:  Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        HStack {
            
            ZStack(alignment: .trailing) {
                HStack {
                    if isObscured {
                        SecureField(title, text: $text).textFieldStyle(ObscuredTextFieldStyle(isObscured: $isObscured))
                    } else {
                        TextField(title, text: $text).textFieldStyle(ObscuredTextFieldStyle(isObscured: $isObscured))
                            .overlay( /// apply a rounded border
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(.systemGray), lineWidth: 1)
                            )
                    }
                }
            }
            
        }
    }
}

struct ObscuredTextFieldStyle: TextFieldStyle {
    
    @Binding var isObscured: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            configuration
            
            
            Button(action: {
                isObscured.toggle()
            }) {
                Image(systemName: self.isObscured ? "eye.slash" : "eye")
                    .accentColor(Color(.gray))
            }
            
        }  .overlay( /// apply a rounded border
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color(.systemGray), lineWidth: 1)
        )
    }
}
