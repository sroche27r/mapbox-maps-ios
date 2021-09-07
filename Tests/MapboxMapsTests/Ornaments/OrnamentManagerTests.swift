import XCTest
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
class OrnamentManagerTests: XCTestCase, AttributionDataSource {

    var ornamentSupportableView: OrnamentSupportableViewMock!
    var options: OrnamentOptions!
    var ornamentsManager: OrnamentsManager!
    var attributionDialogManager: AttributionDialogManager!

    override func setUp() {
        ornamentSupportableView = OrnamentSupportableViewMock(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        options = OrnamentOptions()
        attributionDialogManager = AttributionDialogManager(dataSource: self, delegate: nil)
        ornamentsManager = OrnamentsManager(view: ornamentSupportableView, options: options, infoButtonOrnamentDelegate: attributionDialogManager)
    }

    override func tearDown() {
        ornamentSupportableView = nil
    }

    func testInitializer() {
        XCTAssertEqual(ornamentSupportableView.subviews.count, 4)
        XCTAssertEqual(ornamentsManager.options.attributionButton.margins, options.attributionButton.margins)
    }

    func testHidingOrnament() {
        let initialSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isInitialCompassHidden = initialSubviews.first?.isHidden else {
            XCTFail("Failed to access the compass' isHidden property.")
            return
        }

        XCTAssertEqual(options.compass.visibility, .adaptive)
        options.compass.visibility = .hidden

        ornamentsManager.options = options

        XCTAssertEqual(options.compass.visibility, .hidden)

        let updatedSubviews = ornamentSupportableView.subviews.filter { $0.isKind(of: MapboxCompassOrnamentView.self) }
        guard let isUpdatedCompassHidden = updatedSubviews.first?.isHidden else {
            XCTFail("Failed to access the updated compass' isHidden property.")
            return
        }

        XCTAssertNotEqual(isInitialCompassHidden, isUpdatedCompassHidden)
    }
    func testCompassVisiblityTests() {
        guard let compass = ornamentSupportableView.subviews.compactMap({ $0 as? MapboxCompassOrnamentView}).first else {
            XCTFail("Failed to find compass in subviews")
            return
        }

        struct CompassTest {
            let bearing: Double
            let isHidden: Bool
        }
        struct VisibilityTest {
            let visibility: OrnamentVisibility
            let tests: [CompassTest]
        }

        let tests: [VisibilityTest] = [
            VisibilityTest(visibility: .adaptive,
                           tests: [.init(bearing: 10, isHidden: false), .init(bearing: 0, isHidden: true), .init(bearing: 50, isHidden: false)]),
            VisibilityTest(visibility: .visible,
                           tests: [.init(bearing: 0, isHidden: false), .init(bearing: 50, isHidden: false), .init(bearing: 0, isHidden: false)]),
            VisibilityTest(visibility: .hidden,
                           tests: [.init(bearing: 10, isHidden: true), .init(bearing: 0, isHidden: true), .init(bearing: 50, isHidden: true)])
        ]
        tests.forEach({ visibilityTest in
            self.ornamentsManager.options.compass.visibility = visibilityTest.visibility
            XCTAssertEqual(compass.visibility, visibilityTest.visibility, "Compass visibility did not get set to '\(visibilityTest.visibility)'")
            visibilityTest.tests.forEach({ test in
                // Set bearing
                let cameraState = MapboxCoreMaps.CameraState(center: CLLocationCoordinate2D(latitude: 45.523052, longitude: -122.663649),
                                                             padding: EdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                                             zoom: 15,
                                                             bearing: test.bearing,
                                                             pitch: 0)
                // Mock a camera changed event
                self.ornamentSupportableView.notifyCameraChanged(cameraState: CameraState(cameraState))
                let isHidden = compass.isHidden || compass.containerView.isHidden
                XCTAssertEqual(isHidden,
                               test.isHidden,
                               "Compass visibility '\(visibilityTest.visibility)' compass is \(isHidden ? "hidden" : "visible") with bearing = \(test.bearing)")
            })
        })
    }

    func testScaleBarOnRight() throws {
        let initialSubviews = ornamentSupportableView.subviews.filter { $0 is MapboxScaleBarOrnamentView }

        let scaleBar = try XCTUnwrap(initialSubviews.first as? MapboxScaleBarOrnamentView, "The ornament supportable map view should include a scale bar")
        XCTAssertFalse(scaleBar.isOnRight, "The default scale bar should be on the left initially.")

        ornamentsManager.options.scaleBar.position = .topRight
        XCTAssertTrue(scaleBar.isOnRight, "The scale bar should be on the right after the position has been updated to topRight.")

        ornamentsManager.options.scaleBar.position = .bottomLeft
        XCTAssertFalse(scaleBar.isOnRight, "The default scale bar should be on the left after updating position to bottomLeft.")

        ornamentsManager.options.scaleBar.position = .bottomRight
        XCTAssertTrue(scaleBar.isOnRight, "The scale bar should be on the right after the position has been updated to bottomRight.")
    }

    func attributions() -> [Attribution] {
        return [ Attribution(title: "This is a test", url: URL(string: "https://example.com/this-is-a-test")!)]
    }
}
