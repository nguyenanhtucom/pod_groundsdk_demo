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
import GroundSdk

class UserAccountViewController: UIViewController {

    private let groundSdk = GroundSdk()

    private var userAccountRef: Ref<UserAccount>?

    @IBOutlet var accountProviderTextField: UITextField!
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var userTokenTextField: UITextField!
    @IBOutlet var droneListTextField: UITextField!
    @IBOutlet var setUserButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var setDroneList: UIButton!
    @IBOutlet var lastAction: UILabel!
    @IBOutlet var segmentedCollectedPolicy: UISegmentedControl!
    @IBOutlet var privateModeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        userAccountRef = groundSdk.getFacility(Facilities.userAccount) { _ in }
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editingChanged(self)
    }

    @IBAction func setUserAccount(_ sender: UIButton) {
        doSetUser()
    }

    @IBAction func setDroneList(_ sender: UIButton) {
        doSetDroneList()
    }

    @IBAction func clearUser(_ sender: Any) {
        doClear()
    }

    @IBAction func AllowAnonymousAction(_ sender: Any) {
        doSetAnonymous(true)
    }

    @IBAction func ResuseAnonymousAction(_ sender: Any) {
        doSetAnonymous(false)
    }

    @IBAction func setPrivateMode(_ sender: Any) {
        doSetPrivateMode()
    }

    @IBAction func editingChanged(_ sender: Any) {
        lastAction.text = ""
        let providerString = accountProviderTextField.text ?? ""
        let idString = userIdTextField.text ?? ""
        setUserButton.isEnabled = providerString.count > 0 && idString.count > 0
    }

    private func doClear() {
        if let userAccount = userAccountRef?.value {
            userAccount.clear(dataUploadPolicy: DataUploadPolicy.deny)
            accountProviderTextField.text = ""
            userIdTextField.text = ""
            userTokenTextField.text = ""
            editingChanged(self)
            lastAction.text = "last action = clear action (anonymous: false)"
        }
    }

    private func doSetUser() {
        if let userAccount = userAccountRef?.value {
            let providerString = accountProviderTextField.text ?? ""
            let idString = userIdTextField.text ?? ""
            let token = userTokenTextField.text ?? ""
            let droneList = droneListTextField.text ?? ""
            let dataPolicy = getSelectedUploadPolicy()
            userAccount.set(accountProvider: providerString, accountId: idString,
                dataUploadPolicy: dataPolicy,
                oldDataPolicy: segmentedCollectedPolicy.selectedSegmentIndex == 0 ?
                                OldDataPolicy.denyUpload : OldDataPolicy.allowUpload,
                token: token, droneList: droneList)
            lastAction.text = "last action = set accountProvider and accountId"
        }
    }

    private func doSetDroneList() {
        if let userAccount = userAccountRef?.value {
            let droneList = droneListTextField.text ?? ""
            userAccount.set(droneList: droneList)
            lastAction.text = "last action = set drone list \(droneList)"
        }
    }

    private func doSetAnonymous(_ value: Bool) {
        if let userAccount = userAccountRef?.value {
            userAccount.clear(dataUploadPolicy: value ? DataUploadPolicy.full : DataUploadPolicy.deny)
            accountProviderTextField.text = ""
            userIdTextField.text = ""
            editingChanged(self)
            lastAction.text = "last action = clear / dataUploadPolicy: \(value)"
        }
    }

    private func doSetPrivateMode() {
        if let userAccount = userAccountRef?.value {
            userAccount.set(privateMode: privateModeSwitch.isOn, dataUploadPolicy: getSelectedUploadPolicy())
            lastAction.text = "last action = set private mode"
        }
    }

    private func getSelectedUploadPolicy() -> DataUploadPolicy {
        switch segmentedCollectedPolicy.selectedSegmentIndex {
        case 0:
            return .deny
        case 1:
            return .anonymous
        case 2:
            return .noGps
        case 3:
            return .full
        default:
            return .deny
        }
    }
}

extension UserAccountViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != " " else {
            return false
        }
        return true
    }

}
