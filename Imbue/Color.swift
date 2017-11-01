//
//  Color.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit
import CoreGraphics


// https://web.archive.org/web/20081207061220/http://kb.adobe.com/selfservice/viewContent.do?externalId=310838
// http://www.color-image.com/2011/10/the-reference-white-in-adobe-photoshop-lab-mode/
//let d50WhitePoint: [CGFloat] = [0.9642, 1.0000, 0.8249]
// https://au.mathworks.com/help/images/ref/whitepoint.html?requestedDomain=au.mathworks.com
let d50WhitePoint: [CGFloat] = [0.9642, 1.0000, 0.8251]
//let pcsWhitePoint: [CGFloat] = [0.962, 1.0000, 0.8249]
let blackPoint: [CGFloat] = [0.0, 0.0, 0.0]
let range: [CGFloat] = [-128, 127, -128, 127]
let labD50ColorSpace = d50WhitePoint.withUnsafeBufferPointer { (whitePointBuffer) in
	blackPoint.withUnsafeBufferPointer { (blackPointBuffer) in
		range.withUnsafeBufferPointer { (rangeBuffer) in
			CGColorSpace(labWhitePoint: whitePointBuffer.baseAddress!, blackPoint: blackPointBuffer.baseAddress, range: rangeBuffer.baseAddress)
		}
	}
}!

let extendedLinearSRGBSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB)!
let extendedSRGBSpace = CGColorSpace(name: CGColorSpace.extendedSRGB)!


extension CGColor {
	class func labD50(l: CGFloat, a: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> CGColor? {
		let values: [CGFloat] = [l, a, b, alpha]
		return values.withUnsafeBufferPointer { valuesBuffer in
				return CGColor(colorSpace: labD50ColorSpace, components: valuesBuffer.baseAddress!)
		}
	}
	
	class func linearSRGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> CGColor? {
		let values: [CGFloat] = [r, g, b, alpha]
		return values.withUnsafeBufferPointer { valuesBuffer in
			return CGColor(colorSpace: extendedLinearSRGBSpace, components: valuesBuffer.baseAddress!)
		}
	}
	
	class func sRGB(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) -> CGColor? {
		let values: [CGFloat] = [r, g, b, alpha]
		return values.withUnsafeBufferPointer { valuesBuffer in
			return CGColor(colorSpace: extendedSRGBSpace, components: valuesBuffer.baseAddress!)
		}
	}
	
	func toLabD50() -> CGColor? {
		return self.converted(to: labD50ColorSpace, intent: .defaultIntent, options: nil)
	}
	
	func toLinearSRGB() -> CGColor? {
		return self.converted(to: extendedLinearSRGBSpace, intent: .defaultIntent, options: nil)
	}
	
	func toSRGB() -> CGColor? {
		return self.converted(to: extendedSRGBSpace, intent: .defaultIntent, options: nil)
	}
	
	func toDisplayUIColor() -> UIColor? {
		return self.toSRGB().map{ UIColor(cgColor: $0) }
	}
}

extension CGFloat {
	var hexString: String {
		let clamped: CGFloat = Swift.min(Swift.max(self, 0.0), 1.0)
		let uint255 = UInt8(clamped * 255)
		return String(uint255, radix: 16, uppercase: true)
	}
	
	init?<S>(hexString hexStringInput: S)
		where S : StringProtocol
	{
		let hexString = String(hexStringInput).replacingOccurrences(of: "0x", with: "")
		guard let uint255 = UInt8(hexString, radix: 16)
			else { return nil }
		
		let f0to1 = CGFloat(uint255) / 255.0
		
		self.init(f0to1)
	}
}
