import PlaygroundSupport
import UIKit

let container = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
container.backgroundColor = .white
PlaygroundPage.current.liveView = container

let imageView = UIImageView(frame: container.bounds)
container.addSubview(imageView)

let renderer = UIGraphicsImageRenderer(bounds: imageView.bounds)

// Challenge 1: Pick any emoji and try creating it using Core Graphics.

let image = renderer.image { ctx in
    
    ctx.cgContext.translateBy(x: 100, y: 100)
    
    let face = CGRect(x: -100, y: -100, width: 200, height: 200).insetBy(dx: 5, dy: 5)
    ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
    ctx.cgContext.setStrokeColor(UIColor.orange.cgColor)
    ctx.cgContext.setLineWidth(7)
    ctx.cgContext.addEllipse(in: face)
    ctx.cgContext.drawPath(using: .fillStroke)
    
    let mouth = CGRect(x: -20, y: 25, width: 40, height: 40)
    ctx.cgContext.setFillColor(UIColor.brown.cgColor)
    ctx.cgContext.addEllipse(in: mouth)
    ctx.cgContext.drawPath(using: .fill)
    
    let leftEye = CGRect(x: -45, y: -35, width: 25, height: 30)
    ctx.cgContext.setFillColor(UIColor.brown.cgColor)
    ctx.cgContext.addEllipse(in: leftEye)
    ctx.cgContext.drawPath(using: .fill)
    
    let rightEye = CGRect(x: 20, y: -35, width: 25, height: 30)
    ctx.cgContext.setFillColor(UIColor.brown.cgColor)
    ctx.cgContext.addEllipse(in: rightEye)
    ctx.cgContext.drawPath(using: .fill)
}

imageView.image = image
