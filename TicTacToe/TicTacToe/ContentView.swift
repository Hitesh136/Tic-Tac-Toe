//
//  ContentView.swift
//  TicTacToe
//
//  Created by Hitesh Agarwal on 25/02/20.
//  Copyright © 2020 Hitesh Agarwal. All rights reserved.
//

import SwiftUI
var boxLength: CGFloat {
    (UIScreen.main.bounds.width - (2 * 50)) / 3
}

struct ContentView: View {
    var boxLength: CGFloat {
        (UIScreen.main.bounds.width - (2 * 50)) / 3
    }

    @ObservedObject var viewModel = GameViewModel()
    var body: some View {
        ZStack {
            Color.black
            VStack {
                
                Text("Tic Tac Toe")
                    .font(Font.system(size: 30))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                VStack(spacing: 3) {
                    ForEach(0...2, id: \.self) { yIndex in
                        HStack(spacing: 3) {
                            ForEach(0...2, id: \.self) { xIndex in
                                Text(self.viewModel.getTextFor(xIndex: xIndex, yIndex: yIndex))
                                    .foregroundColor(Color.black)
                                    .font(Font.system(size: 60))
                                    .frame(width: self.boxLength, height: self.boxLength)
                                    .background(Color.white)
                                    .onTapGesture {
                                        self.viewModel.playTile(at_xIndexs: xIndex, and_yIndex: yIndex)
                                }
                            }
                        }
                    }
                }
                .background(Color.black)
                .cornerRadius(10)
                
                Text(self.viewModel.state.message)
                .font(Font.system(size: 30))
                .foregroundColor(.white)
                .padding(.top, 40)
            }
        }.onAppear(perform: {
            self.viewModel.start()
        })
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $viewModel.showActionSheet) {
            let title = self.viewModel.state.message

            return Alert(title: Text(title), message: nil, dismissButton: Alert.Button.default(Text("New Game"), action: {
                
            }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
