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

class InternalUserStorageCell: PeripheralProviderContentCell {
    @IBOutlet weak var fileSystemState: UILabel!
    @IBOutlet weak var physicalState: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var capacity: UILabel!
    @IBOutlet weak var availableSpace: UILabel!
    @IBOutlet weak var isEncryptedLabel: UILabel!
    @IBOutlet weak var hasCheckErrorLabel: UILabel!
    private var storage: Ref<InternalUserStorage>?

    var viewController: UIViewController?

    override func set(peripheralProvider provider: PeripheralProvider) {
        super.set(peripheralProvider: provider)
        selectionStyle = .none
        storage = provider.getPeripheral(Peripherals.internalUserStorage) { [unowned self] storage in
            if let storage = storage {
                self.fileSystemState.text = storage.fileSystemState.description
                self.physicalState.text = storage.physicalState.description
                self.name.text = storage.mediaInfo?.name ?? "-"
                if let capacity = storage.mediaInfo?.capacity {
                    self.capacity.text = ByteCountFormatter.string(fromByteCount: Int64(capacity), countStyle: .file)
                } else {
                    self.capacity.text = "-"
                }
                if storage.availableSpace >= 0 {
                    self.availableSpace.text = ByteCountFormatter.string(
                        fromByteCount: Int64(storage.availableSpace), countStyle: .file)
                } else {
                    self.availableSpace.text = "-"
                }
                self.isEncryptedLabel.text = storage.isEncrypted ? "Encrypted" : "NOT encrypted"
                self.hasCheckErrorLabel.text = storage.hasCheckError?.description ?? "NOT supported"
                self.show()
            } else {
                self.hide()
            }
        }
    }
}
