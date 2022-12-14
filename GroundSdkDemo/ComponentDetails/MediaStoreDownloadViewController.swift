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

class MediaStoreDownloadViewController: UIViewController, MediaListViewController {

    @IBOutlet weak var typeControl: UISegmentedControl!
    @IBOutlet weak var destinationControl: UISegmentedControl!
    @IBOutlet weak var mediaCntView: UILabel!
    @IBOutlet weak var resourceCntView: UILabel!
    @IBOutlet weak var fileProgressView: UIProgressView!
    @IBOutlet weak var totalProgressView: UIProgressView!
    @IBOutlet weak var downloadButton: UIButton!

    private let groundSdk = GroundSdk()
    private var droneUid: String?
    private var medias: [MediaItem]?
    private var downloadRequest: Ref<MediaDownloader>!

    func set(droneUid: String, medias: [MediaItem]) {
        self.droneUid = droneUid
        self.medias = medias
    }

    func download(type: DownloadType, destination: DownloadDestination) {
        if let medias = medias,
            let drone = groundSdk.getDrone(uid: droneUid!),
            let mediaStore: MediaStore = drone.getPeripheral(Peripherals.mediaStore) {

            downloadButton.isEnabled = false

            downloadRequest = mediaStore.newDownloader(
                mediaResources: MediaResourceListFactory.listWith(allOf: medias),
                type: type,
                destination: destination) { [weak self] mediaDownloader in
                    if let mediaDownloader = mediaDownloader {
                        self?.mediaCntView.text =
                        "\(mediaDownloader.currentMediaCount) / \(mediaDownloader.totalMediaCount)"
                        self?.resourceCntView.text =
                        "\(mediaDownloader.currentResourceCount) / \(mediaDownloader.totalResourceCount)"
                        self?.fileProgressView.setProgress(mediaDownloader.currentFileProgress, animated: false)
                        self?.totalProgressView.setProgress(mediaDownloader.totalProgress, animated: false)
                        if mediaDownloader.status != .running {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
                                self?.cancel()
                            }
                        }
                    } else {
                        self?.cancel()
                    }
            }
        } else {
            cancel()
        }
    }

    @IBAction func download() {
        let type: DownloadType = typeControl.selectedSegmentIndex == 0 ? .full : .preview

        switch destinationControl.selectedSegmentIndex {
        case 0:
            if let drone = groundSdk.getDrone(uid: droneUid!) {
                download(type: type, destination: .mediaGallery(albumName: drone.name))
            }
        case 1:
            download(type: type, destination: .tmp)
        case 2:
            download(type: type, destination: .document(directoryName: "medias"))
        case 3:
            let dirPath = (NSTemporaryDirectory() as NSString).appendingPathComponent("medias")
            download(type: type, destination: .directory(path: dirPath))
        default:
            break
        }
    }

    @IBAction func cancel() {
        presentingViewController?.dismiss(animated: true)
    }
}
