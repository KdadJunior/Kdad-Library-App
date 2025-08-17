//
//  NearestLibraryViewController.swift
//  Kdad-Library-App
//
//  Created by user on 8/16/25.
//

import UIKit
import MapKit
import CoreLocation

final class NearestLibraryViewController: UIViewController {

    // MARK: UI
    private let mapView = MKMapView()
    private let activity = UIActivityIndicatorView(style: .large)
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()

    // MARK: Location
    private let locationManager = CLLocationManager()
    private var hasCenteredOnUser = false

    // Fallback city (used if permission denied or no fix yet)
    private let fallbackCoordinate = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090) // Apple Park area

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Find Library"
        view.backgroundColor = .systemBackground
        setupNav()
        setupMap()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        // Check services off the main thread to avoid the analyzer warning.
        checkServicesThenAuthorize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // If user returned without deciding earlier, prompt again
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - Setup
private extension NearestLibraryViewController {
    func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Recenter",
            style: .plain,
            target: self,
            action: #selector(recenter)
        )
    }

    func setupMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        activity.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mapView)
        view.addSubview(activity)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activity.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        mapView.showsUserLocation = true
        mapView.delegate = self
    }
}

// MARK: - Actions
private extension NearestLibraryViewController {
    @objc func dismissSelf() {
        dismiss(animated: true)
    }

    @objc func recenter() {
        if let loc = locationManager.location {
            center(on: loc.coordinate, spanMeters: 2000)
            searchNearbyLibraries(around: loc.coordinate)
        } else {
            // Recenter to fallback if we still don't have a fix
            center(on: fallbackCoordinate, spanMeters: 4000)
            searchNearbyLibraries(around: fallbackCoordinate)
        }
    }
}

// MARK: - Auth handling & helpers
private extension NearestLibraryViewController {
    func checkServicesThenAuthorize() {
        DispatchQueue.global(qos: .userInitiated).async {
            let enabled = CLLocationManager.locationServicesEnabled()
            DispatchQueue.main.async {
                guard enabled else {
                    self.showBusy(false, message: "Location Services are disabled.\nEnable them in Settings.")
                    return
                }
                self.handleAuthorizationStatus(self.locationManager.authorizationStatus)
            }
        }
    }

    func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            showBusy(true, message: "Locating you…")
            locationManager.startUpdatingLocation()

        case .denied, .restricted:
            // Inform user and show fallback search so the screen is still useful
            showLocationDenied()
            center(on: fallbackCoordinate, spanMeters: 4000)
            searchNearbyLibraries(around: fallbackCoordinate)

        @unknown default:
            break
        }
    }

    func center(on coordinate: CLLocationCoordinate2D, spanMeters: CLLocationDistance) {
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: spanMeters,
                                        longitudinalMeters: spanMeters)
        mapView.setRegion(region, animated: true)
    }

    func showBusy(_ on: Bool, message: String? = nil) {
        on ? activity.startAnimating() : activity.stopAnimating()
        statusLabel.text = message
        statusLabel.isHidden = (message == nil)
    }

    func showLocationDenied() {
        let alert = UIAlertController(
            title: "Location Permission Needed",
            message: "Enable location access in Settings to find libraries near you.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url)
        })
        present(alert, animated: true)
    }

    // Shared search runner with graceful fallback handling.
    func startSearch(_ request: MKLocalSearch.Request, isFallback: Bool) {
        MKLocalSearch(request: request).start { [weak self] response, error in
            guard let self = self else { return }
            self.showBusy(false, message: nil)

            if let error = error as NSError? {
                // If POI path failed or throttled, try fallback once
                if !isFallback {
                    // Known flaky codes for POI searches
                    if let code = MKError.Code(rawValue: UInt(error.code)),
                       code == .placemarkNotFound || code == .serverFailure || code == .loadingThrottled {
                        let fallbackReq = MKLocalSearch.Request()
                        fallbackReq.region = request.region
                        fallbackReq.naturalLanguageQuery = "library"
                        self.showBusy(true, message: "Searching nearby libraries…")
                        self.startSearch(fallbackReq, isFallback: true)
                        return
                    }
                }
                self.showBusy(false, message: "Search failed: \(error.localizedDescription)")
                return
            }

            self.mapView.removeAnnotations(self.mapView.annotations.filter { !($0 is MKUserLocation) })

            guard let items = response?.mapItems, !items.isEmpty else {
                // If the POI path returned 0, try natural-language once.
                if !isFallback {
                    let fallbackReq = MKLocalSearch.Request()
                    fallbackReq.region = request.region
                    fallbackReq.naturalLanguageQuery = "library"
                    self.showBusy(true, message: "Searching nearby libraries…")
                    self.startSearch(fallbackReq, isFallback: true)
                } else {
                    self.showBusy(false, message: "No libraries found nearby.")
                }
                return
            }

            let annotations = items.map { item -> MKPointAnnotation in
                let a = MKPointAnnotation()
                a.title = item.name
                if let addr = item.placemark.title { a.subtitle = addr }
                a.coordinate = item.placemark.coordinate
                return a
            }

            self.mapView.addAnnotations(annotations)
            self.mapView.showAnnotations(annotations, animated: true)
        }
    }

    func searchNearbyLibraries(around coordinate: CLLocationCoordinate2D) {
        showBusy(true, message: "Searching nearby libraries…")

        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 5_000,
                                        longitudinalMeters: 5_000)

        // First attempt: POI filter (iOS 13+)
        if #available(iOS 13.0, *) {
            let req = MKLocalSearch.Request()
            req.region = region
            req.resultTypes = .pointOfInterest
            req.pointOfInterestFilter = MKPointOfInterestFilter(including: [.library])
            startSearch(req, isFallback: false)
        } else {
            // Older iOS: direct query
            let req = MKLocalSearch.Request()
            req.region = region
            req.naturalLanguageQuery = "library"
            startSearch(req, isFallback: true)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension NearestLibraryViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus(manager.authorizationStatus)
    }

    // For iOS < 14 (just in case you run on an older device)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorizationStatus(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        if !hasCenteredOnUser {
            hasCenteredOnUser = true
            center(on: loc.coordinate, spanMeters: 2000)
            searchNearbyLibraries(around: loc.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showBusy(false, message: "Location error: \(error.localizedDescription)")
    }
}

// MARK: - MKMapViewDelegate
extension NearestLibraryViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let id = "LibraryPin"
        let view: MKMarkerAnnotationView
        if let v = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView {
            view = v
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
            view.markerTintColor = .systemIndigo
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        view.annotation = annotation
        return view
    }

    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }
        let placemark = MKPlacemark(coordinate: annotation.coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = annotation.title ?? "Library"
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
