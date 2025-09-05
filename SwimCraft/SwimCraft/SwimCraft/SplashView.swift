//
//  SplashView.swift
//  SwimCraft
//
//  Created by Brenna Pavlinchak on 9/4/25.
//

import SwiftUI

struct SplashView: View
{
    @State private var isActive = false
    
    var body: some View
    {
        if isActive
        {
            MonthlySummaryView()
                .environment(\.managedObjectContext, PersistenceController.shared.context)
        }
        else
        {
            ZStack
            {
                LinearGradient(gradient: Gradient(colors: [Color(customHex: "#153B50"), Color(customHex: "#429EA6").opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                Image("imagefemale")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 700, height: 700)
                    .ignoresSafeArea()
            }
            .onAppear
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)
                {
                    withAnimation(.easeInOut(duration: 0.5))
                    {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview
{
    SplashView()
}
