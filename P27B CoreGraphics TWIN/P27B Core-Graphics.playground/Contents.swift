import PlaygroundSupport
import UIKit

let container = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
container.backgroundColor = .white
PlaygroundPage.current.liveView = container

let imageView = UIImageView(frame: container.bounds)
container.addSubview(imageView)

let renderer = UIGraphicsImageRenderer(bounds: imageView.bounds)

// Challenge 1: Use a combination of move(to:) and addLine(to:) to create and stroke a path that spells “TWIN” on the canvas.

let image = renderer.image { ctx in
    
    let cx = ctx.cgContext
    cx.setStrokeColor(UIColor.black.cgColor)
    cx.setLineWidth(1)
    
    // T
    cx.move(to: CGPoint(x: 35, y: 40))
    cx.addLine(to: CGPoint(x: 106, y: 40))
    cx.move(to: CGPoint(x: 70, y: 40))
    cx.addLine(to: CGPoint(x: 70, y: 158))
    
    // W
    cx.move(to: CGPoint(x: 121, y: 40))
    cx.addLine(to: CGPoint(x: 146, y: 158))
    cx.move(to: CGPoint(x: 146, y: 158))
    cx.addLine(to: CGPoint(x: 174, y: 40))
    cx.move(to: CGPoint(x: 174, y: 40))
    cx.addLine(to: CGPoint(x: 199, y: 158))
    cx.move(to: CGPoint(x: 199, y: 158))
    cx.addLine(to: CGPoint(x: 227, y: 40))
    
    // I
    cx.move(to: CGPoint(x: 251, y: 40))
    cx.addLine(to: CGPoint(x: 251, y: 158))
    
    // N
    cx.move(to: CGPoint(x: 286, y: 40))
    cx.addLine(to: CGPoint(x: 286, y: 158))
    cx.move(to: CGPoint(x: 286, y: 40))
    cx.addLine(to: CGPoint(x: 347, y: 158))
    cx.move(to: CGPoint(x: 347, y: 40))
    cx.addLine(to: CGPoint(x: 347, y: 158))
    
    cx.drawPath(using: .fillStroke)
}

imageView.image = image
