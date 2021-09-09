import UIKit
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
// Mock class that flags true when `OrnamentSupportableView` protocol methods have been called on it
class OrnamentSupportableViewMock: UIView, OrnamentSupportableView {
    private var subscribers: [(CameraState) -> Void] = []

    func subscribeCameraChangeHandler(_ handler: @escaping (CameraState) -> Void) {
        subscribers.append(handler)
    }
    // Notifys all subscribers of a chamera changed event
    func notifyCameraChanged(cameraState: CameraState) {
        subscribers.forEach({ $0(cameraState) })
    }
    var tapCalled: Bool = false

    func tapped() {
        tapCalled = true
    }
}
