//
//  WGIdenticon.swift
//  X03F2
//
//  Created by Mark Morrill on 2017/04/19.
//  Copyright © 2017 WeGame Corp. All rights reserved.
//

import CoreGraphics
import SpriteKit

public extension CGRect {
    var center:CGPoint {
        get {
            return self.origin + CGPoint(x: self.width/2, y: self.height/2)
        }
        set {
            self.origin = newValue - CGPoint(x: self.width/2, y: self.height/2)
        }
    }
}

public func + (left:CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left:CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func * (point:CGPoint, scalar:CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}



public class WGIdenticon: IconGenerator {
    
    // the points are from 0.0 ... 10.0 rather than 0.0 ... 1.0 for no reason other than I find it easier to type
    // swap means that the fill and stroke colors are swapped.
    private let splines:[(swap:Bool,points:[CGPoint])] = [
        (swap:false, points:[CGPoint(x:2.0, y:1.2), CGPoint(x:7.5, y:4.4), CGPoint(x:10.0, y:0.0)]),
        (swap:false, points:[CGPoint(x:1, y:1), CGPoint(x:1, y:3), CGPoint(x:2, y:3), CGPoint(x:2, y:1), CGPoint(x:3, y:1), CGPoint(x:3, y:4), CGPoint(x:4, y:4), CGPoint(x:4, y:1), CGPoint(x:5, y:0)]),
        (swap:false, points:[CGPoint(x:3, y:0.8), CGPoint(x:7, y:1.6), CGPoint(x:6, y:3.2), CGPoint(x:10, y:3.2), CGPoint(x:9, y:0)]),
        (swap:false, points:[CGPoint(x:3, y:0.8), CGPoint(x:5, y:2.8), CGPoint(x:8, y:3.2), CGPoint(x:7, y:1), CGPoint(x:10, y:0)]),
        (swap:false, points:[CGPoint(x:0, y:0), CGPoint(x:7, y:2.4), CGPoint(x:9, y:5.6), CGPoint(x:10, y:2.4), CGPoint(x:6, y:0)]),
        (swap:false, points:[CGPoint(x:2, y:2), CGPoint(x:5,y:0), CGPoint(x:7.5, y:4), CGPoint(x:10, y:0)]),
        (swap:false, points:[CGPoint(x:0, y:0), CGPoint(x:6,y:3), CGPoint(x:10, y:0)]),
        (swap:false, points:[CGPoint(x:4, y:4), CGPoint(x:6,y:2), CGPoint(x:10, y:3)]),
        
        (swap:true, points:[CGPoint(x:4, y:-4), CGPoint(x:6,y:-2), CGPoint(x:10, y:-3)]),
        (swap:true, points:[CGPoint(x:5,y:1), CGPoint(x:6,y:3), CGPoint(x:8,y:3), CGPoint(x:9,y:0), ]),
        (swap:true, points:[CGPoint(x:5,y:1), CGPoint(x:6,y:3), CGPoint(x:8,y:-3), CGPoint(x:9,y:0), ]),
        (swap:true, points:[CGPoint(x:1,y:0.2), CGPoint(x:3,y:1.5), CGPoint(x:5,y:5), CGPoint(x:6,y:0), ]),
        (swap:true, points:[CGPoint(x:1,y:0.2), CGPoint(x:3,y:1.5), CGPoint(x:5,y:-5), CGPoint(x:6,y:0), ]),
        (swap:true, points:[CGPoint(x:4,y:0), CGPoint(x:3,y:1), CGPoint(x:5,y:6), CGPoint(x:8,y:2), CGPoint(x:5,y:0), ]),
        (swap:true, points:[CGPoint(x:4,y:0), CGPoint(x:3,y:1), CGPoint(x:5,y:-6), CGPoint(x:8,y:2), CGPoint(x:5,y:0), ]),
        (swap:true, points:[CGPoint(x:8,y:0), CGPoint(x:8,y:1.6), CGPoint(x:7,y:2.4), CGPoint(x:2,y:0.3), CGPoint(x:7,y:3.2), CGPoint(x:9,y:1.8), CGPoint(x:8,y:0), ]),
        ]
    
    
    public init() {}
    
    public func icon(from number: UInt32, size: CGSize) -> CGImage {
        
        let box     = CGRect(origin:CGPoint.zero, size:size)
        let center  = box.center
        
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )!
        
        // which spline being used is pulled from the splines based on number. UInt32 is 4 x 8 bit numbers.
        var src = number
        let pull = {()->(swap:Bool, points:[CGPoint]) in
            let index = Int(src & 0x000F)
            src >>= 8
            return self.splines[index % self.splines.count]
        }
        
        // this snowflake has the point at the top so the outer radius is the size.height/2 and the offset rotation is π/2
        let cubit = size.height/2
        let theta = CGFloat(Double.pi/2)
        let transform = {(pt:CGPoint, mirror:Bool, rotation:CGFloat) -> CGPoint in
            var pt = pt * (cubit / 10)
            if mirror {
                pt.y = -pt.y
            }
            let cosR = cos(rotation+theta)
            let sinR = sin(rotation+theta)
            let x = pt.x * cosR - pt.y * sinR
            let y = pt.x * sinR + pt.y * cosR
            return CGPoint(x: x, y: y) + center
        }
        
        // I like antialias
        context.setShouldAntialias(true)
        
        context.setFillColor(CGColor.color(from: 0xFFFF))
        context.fill(box)
        
        let fillColor   = CGColor.color(from: UInt16(number >> 16))
        let strokeColor = CGColor.color(from: UInt16(number & 0x00FF))
        let alphas:[CGFloat] = [1.0, 0.75, 0.5, 0.25]
        
        for i in 0 ..< 4 {
            let path = CGMutablePath()
            let src = pull()
            let alpha = alphas[i]
            
            for ord in 0 ..< 6 {
                let rotation = CGFloat(ord) * CGFloat(Double.pi/3)
                let sub = CGMutablePath()
                sub.move(to: transform(src.points[0], false, rotation))
                for pt in src.points.dropFirst() {
                    sub.addLine(to: transform(pt, false, rotation))
                }
                for pt in src.points.reversed().dropFirst() {
                    sub.addLine(to: transform(pt, true, rotation))
                }
                sub.closeSubpath()
                path.addPath(sub)
            }
            
            context.saveGState()
            if  src.swap {
                context.setStrokeColor(fillColor.copy(alpha: alpha)!)
                context.setFillColor(strokeColor.copy(alpha: alpha)!)
            } else {
                context.setStrokeColor(strokeColor.copy(alpha: alpha)!)
                context.setFillColor(fillColor.copy(alpha: alpha)!)
            }
            context.addPath(path)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            
            context.restoreGState()
        }
        
        
        return context.makeImage()!
    }
}
