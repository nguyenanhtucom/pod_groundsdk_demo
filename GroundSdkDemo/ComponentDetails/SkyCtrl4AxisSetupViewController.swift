// Copyright (C) 2021 Parrot Drones SAS
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

class SkyCtrl4AxisSetupViewController: UIViewController, DeviceViewController {

    private let groundSdk = GroundSdk()
    private var rcUid: String?
    private var skyCtrl4Gamepad: Ref<SkyCtrl4Gamepad>?

    private var currentDroneModel: Drone.Model?
    private var axesAsArray = Array(SkyCtrl4Axis.allCases).sorted { $0.rawValue < $1.rawValue }

    @IBOutlet private weak var tabBar: UITabBar!
    @IBOutlet private weak var tableView: UITableView!

    func setDeviceUid(_ uid: String) {
        rcUid = uid
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let remoteControl = groundSdk.getRemoteControl(uid: rcUid!) {
            skyCtrl4Gamepad =
                remoteControl.getPeripheral(Peripherals.skyCtrl4Gamepad) { [weak self] skyCtrl4Gamepad in
                    if let skyCtrl4Gamepad = skyCtrl4Gamepad {
                        self?.updateTabBar(skyCtrl4Gamepad: skyCtrl4Gamepad)

                        // reload data
                        self?.reloadDataIfNeeded()

                    } else {
                        self?.performSegue(withIdentifier: "exit", sender: self)
                    }
            }
        }
    }

    private func updateTabBar(skyCtrl4Gamepad: SkyCtrl4Gamepad) {
        var tabBarItems = [UITabBarItem]()
        for supportedDrone in skyCtrl4Gamepad.supportedDroneModels {
            let tabBarItem = UITabBarItem(title: supportedDrone.description, image: nil, tag: supportedDrone.rawValue)
            tabBarItem.badgeValue = (skyCtrl4Gamepad.activeDroneModel == supportedDrone) ? "*" : nil

            tabBarItems.append(tabBarItem)
        }
        tabBarItems.sort(by: { return $0.tag <= $1.tag })
        if tabBar.items == nil || tabBarItems != tabBar.items! {
            tabBar.setItems(tabBarItems, animated: false)
        }

        if currentDroneModel == nil {
            if skyCtrl4Gamepad.activeDroneModel != nil {
                currentDroneModel = skyCtrl4Gamepad.activeDroneModel
            } else if tabBarItems.count > 0 {
                currentDroneModel = Drone.Model(rawValue: tabBarItems[0].tag)
            }
        }

        if currentDroneModel != nil {
            var tabItem: UITabBarItem?
            tabBarItems.forEach {
                if Drone.Model(rawValue: $0.tag) == currentDroneModel {
                    tabItem = $0
                    return
                }
            }
            tabBar.selectedItem = tabItem
        }
    }

    private func reloadDataIfNeeded() {
        if currentDroneModel != nil {
            tableView.reloadData()
        }
    }
}

extension SkyCtrl4AxisSetupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentDroneModel != nil) ? axesAsArray.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "axis", for: indexPath)
        if let cell = cell as? SkyCtrl4AxisSetupCell {

            let editAxis: (_ axis: SkyCtrl4Axis, _ interpolator: AxisInterpolator, _ isReverted: Bool) -> Void = {
                if let skyCtrl4Gamepad = self.skyCtrl4Gamepad?.value, let currentDroneModel = self.currentDroneModel {
                    skyCtrl4Gamepad.set(interpolator: $1, forAxis: $0, droneModel: currentDroneModel)
                    if skyCtrl4Gamepad.reversedAxes(forDroneModel: currentDroneModel)!.contains($0) != $2 {
                        skyCtrl4Gamepad.reverse(axis: $0, forDroneModel: currentDroneModel)
                    }
                }
            }

            if let skyCtrl4Gamepad = self.skyCtrl4Gamepad?.value, let currentDroneModel = self.currentDroneModel {
                let axis = axesAsArray[indexPath.row]
                let isReversed = skyCtrl4Gamepad.reversedAxes(forDroneModel: currentDroneModel)!.contains(axis)
                let interpolator = skyCtrl4Gamepad.interpolator(
                    forAxis: axis, droneModel: currentDroneModel)!
                cell.updateWith(axis: axis, interpolator: interpolator, isReversed: isReversed, editAxis: editAxis)
            }

        }
        return cell
    }
}

extension SkyCtrl4AxisSetupViewController: UITabBarDelegate {
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        currentDroneModel = Drone.Model(rawValue: item.tag)
        reloadDataIfNeeded()
    }
}

class SkyCtrl4AxisSetupCell: UITableViewCell {
    @IBOutlet weak var axisLabel: UILabel!
    @IBOutlet weak var interpolatorPicker: UISegmentedControl!
    @IBOutlet weak var reversedSwitch: UISwitch!

    private var axis: SkyCtrl4Axis!
    private var editAxis: ((_ axis: SkyCtrl4Axis, _ interpolator: AxisInterpolator, _ isReverted: Bool) -> Void)?

    func updateWith(
        axis: SkyCtrl4Axis, interpolator: AxisInterpolator, isReversed: Bool,
        editAxis: ((_ axis: SkyCtrl4Axis, _ interpolator: AxisInterpolator, _ isReverted: Bool) -> Void)?) {

        self.axis = axis
        self.editAxis = editAxis

        axisLabel.text = axis.description
        interpolatorPicker.selectedSegmentIndex = interpolator.rawValue
        reversedSwitch.setOn(isReversed, animated: false)
    }

    @IBAction func onValueChanged(_ sender: Any) {
        editAxis?(axis, AxisInterpolator(rawValue: interpolatorPicker.selectedSegmentIndex)!, reversedSwitch.isOn)
    }
}
