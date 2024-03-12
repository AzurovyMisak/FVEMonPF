//
//  WireTopRight.swift
//  FVEMonPF
//
//  Created by Majkl on 19.03.2024.
//

import SwiftUI

struct WireTopRight: Shape {
    func path(in rect: CGRect) -> Path {
        return WireTopRight.kresliDrat(in: rect)
    }
    
    static func kresliDrat(in rect: CGRect) -> Path {
        let vyska = rect.size.height
        let sirka = rect.size.width
        let corner: CGFloat = 20
        var cesta = Path()
        
        cesta.move(to: CGPoint(x: sirka, y: 0))
        cesta.addLine(to: CGPoint(x: corner, y: 0))
        cesta.addCurve(to: CGPoint(x: 0, y: corner),
                       control1: CGPoint(x: 0, y: 0),
                       control2: CGPoint(x: 0, y: corner))
        cesta.addLine(to: CGPoint(x: 0, y: vyska))
        return cesta
    }
    
}

struct AnimTopRightIn : View {
    @State private var flag : Bool = false
    @State private var dim: Bool = false
    var body: some View {
        WireTopRight()
            .stroke(
                LinearGradient(gradient: Gradient(colors: [Color("wire-gradient-light"),Color("wire-gradient-dark")]), startPoint: .trailing, endPoint: .leading),
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round,
                    lineJoin: .miter))
            .foregroundColor(.blue)
            .frame(width: 105, height: 35)
            
        Image(systemName: "oval.fill")
            .resizable()
            .foregroundColor(Color("wire-running-point"))
            .frame(width: 8, height: 8).offset(x: -3, y: -4)
            //.scaleEffect(dim ? 1.0 : 0.7)
            .opacity(dim ? 0.2 : 1)
            .modifier(FollowEffect(
                pct: self.flag ? 1 : 0,
                path: WireTopRight.kresliDrat(
                    in: CGRect(
                        x: 0,
                        y: 0,
                        width: 105,
                        height: 35)).offsetBy(dx: -49, dy: -43.3),
                rotate: false))
            .onAppear {
                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    self.flag.toggle()
                }
                withAnimation(.easeIn(duration: 2.0).repeatForever(autoreverses: false)) {
                    self.dim.toggle()
                }
            }
    }
}

struct AnimTopRightOut: View {
    @State private var flag : Bool = false
    @State private var dim: Bool = false
    var body: some View {
        WireTopRight()
            .stroke(
                LinearGradient(gradient: Gradient(colors: [Color("wire-gradient-light"),Color("wire-gradient-dark")]), startPoint: .trailing, endPoint: .leading),
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round,
                    lineJoin: .miter))
            .foregroundColor(.blue)
            .frame(width: 105, height: 35)
        
        Image(systemName: "oval.fill")
            .resizable()
            .foregroundColor(Color("wire-running-point"))
            .frame(width: 8, height: 8).offset(x: -3, y: -4)
            //.scaleEffect(dim ? 1.0 : 0.7)
            .opacity(dim ? 1 : 0.2)
            .modifier(FollowEffect(
                pct: self.flag ? 0 : 1,
                path: WireTopRight.kresliDrat(
                    in: CGRect(
                        x: 0,
                        y: 0,
                        width: 105,
                        height: 35)).offsetBy(dx: -49, dy: -43.3),
                rotate: false))
            .onAppear {
                withAnimation(Animation.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    self.flag.toggle()
                }
                withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                    self.dim.toggle()
                }
            }
    }
}

#Preview {
    //AnimTopRightIn()
    AnimTopRightOut()
}
