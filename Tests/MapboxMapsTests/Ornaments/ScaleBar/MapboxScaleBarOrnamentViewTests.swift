import XCTest
@testable import MapboxMaps

class MapboxScaleBarOrnamentViewTests: MapViewIntegrationTestCase {

    func testImperialScaleBar() {
        let scaleBar = MockMapboxScaleBarOrnamentView()
        scaleBar._isMetricLocale = false
        let rows = MapboxScaleBarOrnamentView.Constants.imperialTable

        for row in rows {
            // Add 0.01 so that the converted distance is slightly greater than the distance we are comparing.
            scaleBar.metersPerPoint =  scaleBar.metersFromFeet(row.distance + 0.01)

            let numberOfBars = scaleBar.preferredRow().numberOfBars
            XCTAssertEqual(numberOfBars, row.numberOfBars, "The number of scale bars should be \(row.numberOfBars) when there are \(scaleBar.metersPerPoint) feet per point.")
        }
    }

    func testMetricScaleBar() {
        let scaleBar = MockMapboxScaleBarOrnamentView()

        let rows = MapboxScaleBarOrnamentView.Constants.metricTable
        for row in rows {
            // Add 0.01 so that the converted distance is slightly greater than the distance we are comparing.
            let distance = (row.distance + 0.01) / Double(scaleBar.maximumWidth)
            scaleBar.metersPerPoint = distance

            let numberOfBars = scaleBar.preferredRow().numberOfBars
            XCTAssertEqual(numberOfBars, row.numberOfBars, "The number of scale bars should be \(row.numberOfBars) when there are \(scaleBar.unitsPerPoint) meters per point.")
        }
    }

// Fails 1 time XCTAssertEqual failed: ("3") is not equal to ("2") - 2 should be visible at 10830.76928205128.
    func testVisibleBars() throws {
        let mapView = try XCTUnwrap(self.mapView, "Map view could not be found")

        let initialSubviews = mapView.subviews.filter { $0 is MapboxScaleBarOrnamentView }

        let scaleBar = try XCTUnwrap(initialSubviews.first as? MapboxScaleBarOrnamentView, "The MapView should include a scale bar as a subview")

        let rows = MapboxScaleBarOrnamentView.Constants.imperialTable
        for row in rows {
            if !scaleBar.staticContainerView.isHidden {
                scaleBar.metersPerPoint =  scaleBar.metersFromFeet(row.distance + 0.01)
                scaleBar.layoutSubviews()

                let numberOfBars = scaleBar.preferredRow().numberOfBars
                let visibleBars = scaleBar.bars.filter{ $0.isHidden == false }
                XCTAssertEqual(visibleBars.count, Int(numberOfBars), "\(numberOfBars) should be visible at \(scaleBar.unitsPerPoint).")
            }
        }
    }
}

final class MockMapboxScaleBarOrnamentView: MapboxScaleBarOrnamentView {
    override var maximumWidth: CGFloat {
        return 195
    }
    
    internal var _isMetricLocale: Bool = true
    
    override var isMetricLocale: Bool {
        return _isMetricLocale
    }
}

fileprivate extension MapboxScaleBarOrnamentView {
    // Reverses the conversions we do to get the distance in feet for the scale bar.
    func metersFromFeet(_ distance: Double) -> Double {
        let dividedByWidth = distance / Double(maximumWidth)
        let inMeters = dividedByWidth / Constants.feetPerMeter
        return inMeters
    }
}
