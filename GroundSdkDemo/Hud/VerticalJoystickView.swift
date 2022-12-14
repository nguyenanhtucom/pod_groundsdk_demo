// Copyright (C) 2019 Parrot Drones SAS
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of the Parrot Company nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    PARROT COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.

import UIKit

@IBDesignable class VerticalJoystickView: UIControl {

    private static let centerRadius: CGFloat = 25

    @IBInspectable var isVertical: Bool = true
    @IBInspectable var isHorizontal: Bool = true

    private let centerRound: UIBezierPath = UIBezierPath(ovalIn: CGRect(x: -centerRadius, y: -centerRadius,
        width: centerRadius * 2, height: centerRadius * 2))
    private let centerRoundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
    private let borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.05)

    private var offset: CGFloat = 0

    var value: Int {
        return Int(-offset / (bounds.midY - VerticalJoystickView.centerRadius) * 100)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        borderColor.setFill()
        let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.midX).cgPath
        ctx!.addPath(clipPath)
        ctx!.closePath()
        ctx!.fillPath()

        ctx!.translateBy(x: bounds.midX, y: bounds.midY + offset)
        centerRoundColor.setFill()
        centerRound.fill()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackTouch(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTouch()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTouch()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        trackTouch(touches)
    }

    private func trackTouch(_ touches: Set<UITouch>) {
        if let touch = touches.first {
            let touchPoint = touch.location(in: self)

            offset = touchPoint.y - bounds.midY
            let aby2 = pow(offset, 2)
            let radiusy2 = pow((bounds.midY - VerticalJoystickView.centerRadius), 2)
            if aby2 > radiusy2 {
                let delta = sqrt(radiusy2) / sqrt(aby2)
                offset *= delta
            }
            setNeedsDisplay()
            sendActions(for: .valueChanged)
        }
    }

    private func resetTouch() {
        // no action on reset
    }
}
