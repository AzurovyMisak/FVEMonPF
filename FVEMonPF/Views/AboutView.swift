//
//  AboutView.swift
//  FVEMonPF
//
//  Created by Majkl on 27.03.2024.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack() {
            
            Text("Photo Voltaic")
                .foregroundColor(Color("theme_gray_3"))
                .font(.system(size: 40, weight: .heavy))
            Text("Plant Monitoring")
                .foregroundColor(Color("theme_gray_3"))
                .font(.system(size: 40, weight: .heavy))
            Text("Created by Majk for Pavel Formánek").foregroundColor(Color("theme_gray_5")).padding()
            Text("mipsandev@outlook.com").padding()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("theme_gray_9"))
    }
}

#Preview {
    AboutView()
}
