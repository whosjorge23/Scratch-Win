//
//  Home.swift
//  Scratch&Win
//
//  Created by Jorge Giannotta on 08/06/21.
//

import SwiftUI

struct Home: View {
    
    @State var onFinish : Bool = false
    @State var buyTicket : Bool = false
    @State var randomAmount : Int = Int.random(in: 0...22)
    var amounts = [0,0,0,0,1,1,1,1,2,2,2,2,2,2,2,5,10,15,20,25,50,100,1000]
    @State var score = 5
    
    var body: some View {
        VStack(alignment: .center, spacing: nil, content: {
            ScratchCardView(cursorSize: 50, onFinish: $onFinish) {
                //Body Content
                VStack(alignment: .center, spacing: nil, content: {
                    Image("win2")
                        .resizable()
                        .scaledToFit()
                    Text("YOU WON")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("$\(amounts[randomAmount])")
                        .font(.title)
                        .fontWeight(.bold)
                })
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .foregroundColor(.gray)
                
            } overlayView: {
                //Overlay
                Image("scratch")
                    .resizable()
                    .scaledToFit()
//                SwiftUIView()
//                    .foregroundColor(.blue)
            }
            Text("Money: $\(score)")
                .foregroundColor(.white)
                .font(.title)
                .fontWeight(.semibold)
                .padding(30)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onChange(of: onFinish, perform: { value in
            if value {
                score += amounts[randomAmount]
            }
        })
        .overlay(
            HStack(alignment: .center, spacing: nil, content: {
                Button(action: {
                    if onFinish == true {
                        buyTicket = true
                    }
                    onFinish = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                        randomAmount = Int.random(in: 0...22)
                        if score > 1 && buyTicket == true{
                            score -= 1
                            buyTicket = false
                        }
                    }
                    
                }, label: {
                    Capsule()
                        .frame(width: 120, height: 50, alignment: .center)
                        .accentColor(.gray)
                        .overlay(
                            Text("Buy One")
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        )
                })
            })
            .padding()
            ,alignment: .top
        )
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

//Create Custom View with View Builder
struct ScratchCardView<Content: View, OverlayView: View>: View {

    var content: Content
    var overlayView : OverlayView
    
    init(cursorSize: CGFloat, onFinish: Binding<Bool>,@ViewBuilder content: @escaping ()->Content, @ViewBuilder overlayView: @escaping ()->OverlayView) {
        self.content = content()
        self.overlayView = overlayView()
        self.cursorSize = cursorSize
        self._onFinish = onFinish
    }
    
    //Scratch Effect
    @State var startingPoint: CGPoint = .zero
    @State var points: [CGPoint] = []
    
    //Gesture Updates
    @GestureState var gestureLocation: CGPoint = . zero
    
    //Customisation and on finish....
    var cursorSize: CGFloat
    @Binding var onFinish: Bool
    
    var body : some View {
        
        ZStack{
            
            overlayView
                .opacity(onFinish ? 0 : 1)
            
            content
                .mask(
                    ZStack{
                        if !onFinish {
                            ScratchMask(points: points, startingPoint: startingPoint)
                                .stroke(style: StrokeStyle(lineWidth: cursorSize, lineCap: .round, lineJoin: .round))
                        }
                        else {
                            //Show Full Content
                            Rectangle()
                        }
                    }
                )
                .animation(.easeInOut)
                .gesture(
                
                    DragGesture()
                        .updating($gestureLocation, body: { (value, out, _) in
                            
                            out = value.location
                            
                            DispatchQueue.main.async {
                                
                                //Updating Starting Point and add user drag location
                                if startingPoint == .zero {
                                    startingPoint = value.location
                                }
                                
                                points.append(value.location)
                            }
                        })
                        .onEnded({ (value) in
                            withAnimation{
                                onFinish = true
                            }
                        })
                )
            
        }
        .frame(width: 300, height: 300)
        .cornerRadius(20)
        .onChange(of: onFinish, perform: { value in
            //Check and Reset View
            if !onFinish && !points.isEmpty {
                withAnimation(.easeInOut) {
                    resetView()
                }
            }
        })
    }
    
    func resetView() {
        points.removeAll()
        startingPoint = .zero
    }
    
}

//Scratch Mask Shape

struct ScratchMask : Shape {
    var points: [CGPoint]
    var startingPoint: CGPoint

    func path(in rect: CGRect) -> Path {

        return Path{path in

            path.move(to: startingPoint)
            path.addLines(points)
        }
    }
}
