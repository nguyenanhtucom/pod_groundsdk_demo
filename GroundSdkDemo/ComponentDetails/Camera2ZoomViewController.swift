// Copyright (C) 2020 Parrot Drones SAS
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
import GroundSdk

/// A view controller that can modify the zoom.
class Camera2ZoomViewController: UIViewController {

    @IBOutlet weak var zoomLevelLabel: UILabel!
    @IBOutlet weak var zoomLevelSlider: UISlider!
    @IBOutlet weak var zoomVelocityLabel: UILabel!
    @IBOutlet weak var zoomVelocitySlider: UISlider!

    private let groundSdk = GroundSdk()
    private var zoom: Ref<Camera2Zoom>?
    private var droneUid: String!

    private var isEditingLevel = false

    func setDeviceUid(_ uid: String) {
        droneUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        zoomVelocitySlider.minimumValue = -1.0
        zoomLevelSlider.minimumValue = 1.0
        set(zoomVelocity: 0.0)

        if let drone = groundSdk.getDrone(uid: droneUid),
            let camera = drone.getPeripheral(Peripherals.mainCamera2) {
            zoom = camera.getComponent(Camera2Components.zoom) { [weak self] zoom in
                if let zoom = zoom, let `self` = self {
                    self.zoomLevelLabel.text = "x\(String(format: "%.2f", zoom.level))"
                    self.zoomLevelLabel.textColor =
                        (zoom.level <= zoom.maxLossLessLevel) ? UIColor.black : UIColor.orange

                    self.zoomLevelSlider.maximumValue = Float(zoom.maxLevel)
                } else {
                    self?.performSegue(withIdentifier: "exit", sender: self)
                }
            }
        } else {
            performSegue(withIdentifier: "exit", sender: self)
        }
    }

    private func set(zoomVelocity: Double) {
        zoomVelocitySlider.value = Float(zoomVelocity)
        zoomVelocitySlider.sendActions(for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // only set the zoom level slider value when the view will appear.
        // After that, we let it where the user placed it.
        if let zoom = zoom?.value {
            zoomLevelSlider.value = Float(zoom.level)
        }
    }

    @IBAction func zoomLevelDidChange(_ sender: UISlider) {
        zoom?.value?.control(mode: .level, target: Double(sender.value))
    }

    @IBAction func zoomVelocityDidChange(_ sender: UISlider) {
        if let drone = groundSdk.getDrone(uid: droneUid),
            let camera = drone.getPeripheral(Peripherals.mainCamera2),
            let zoom = zoom?.value {
            let percentValue = Double(sender.value)
            zoom.control(mode: .velocity, target: percentValue)
            if let zoomMaxSpeed = camera.config[Camera2Params.zoomMaxSpeed]?.value {
                let velocityValue = percentValue * zoomMaxSpeed
                zoomVelocityLabel.text = "\(String(format: "%.2f", velocityValue)) tan(deg)/sec"
            } else {
                zoomVelocityLabel.text = "-"
            }
        }
    }

    @IBAction func zoomVelocityDidEndEditing(_ sender: UISlider) {
        set(zoomVelocity: 0.0)
    }

    @IBAction func zoomResetLevel(_ sender: UIButton) {
        zoom?.value?.resetLevel()
    }
}
