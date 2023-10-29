//
//  ContentView.swift
//  AsyncAwaitExample
//
//  Created by 송성욱 on 10/29/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = AsyncAwaitVM()
    
    var body: some View {
        List(viewModel.dataArray, id: \.self) { data in
            Text(data)
                .font(.headline)
                .fontWeight(.bold)
        }
        .onAppear {
            Task {
                await viewModel.addFirstAuthor()
                await viewModel.addSomething()
                let finalText = "Final Text: \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
}

#Preview {
    HomeView()
}
