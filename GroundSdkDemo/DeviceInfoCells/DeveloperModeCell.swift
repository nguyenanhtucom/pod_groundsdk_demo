// Copyright (C) 2022 Parrot Drones SAS
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

class DeveloperModeCell: PeripheralProviderContentCell {

    @IBOutlet private weak var adbStateLabel: UILabel!
    @IBOutlet private weak var directConnectionLabel: UILabel!
    private var debugShell: Ref<DebugShell>?
    private var networkControl: Ref<NetworkControl>?

    var viewController: UIViewController?

    override func set(peripheralProvider: PeripheralProvider) {
        super.set(peripheralProvider: peripheralProvider)
        debugShell = peripheralProvider.getPeripheral(Peripherals.debugShell) { [unowned self] debugShell in
            adbStateLabel.text = debugShell?.state.value.description ?? "-"
            updateVisibility()
        }
        networkControl = peripheralProvider.getPeripheral(Peripherals.networkControl) { [unowned self] networkControl in
            directConnectionLabel.text = networkControl?.directConnection.mode.description ?? "-"
            updateVisibility()
        }
    }

    private func updateVisibility() {
        if debugShell != nil || networkControl != nil {
            self.show()
        } else {
            self.hide()
        }
    }
}