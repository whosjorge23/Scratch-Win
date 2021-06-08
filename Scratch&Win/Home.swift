//
//  Home.swift
//  Scratch&Win
//
//  Created by Jorge Giannotta on 08/06/21.
//

import SwiftUI

struct Home: View {
    
    @State var onFinish : Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: nil, content: {
            
            ScratchCardView(cursorSize: 50, onFinish: $onFinish) {
                //Body Content
                VStack(alignment: .center, spacing: nil, content: {
                    Image("2")
                        .resizable()
                        .scaledToFit()
                    Text("YOU WON")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("$300")
                        .font(.title3)
                        .fontWeight(.bold)
                })
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                
            } overlayView: {
                //Overlay
                Image("1")
                    .resizable()
                    .scaledToFit()
            }

            
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .overlay(
            HStack(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Button(action: {
                    onFinish = false
                }, label: {
                    Text("Button")
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
