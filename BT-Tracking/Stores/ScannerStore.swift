//
//  ScannerStore.swift
//  BT-Tracking
//
//  Created by Tomas Svoboda on 18/03/2020.
//  Copyright © 2020 Covid19CZ. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

class ScannerStore {

    let scans: Observable<[DeviceScan]>
    
    private let realm = try! Realm()
    private let scanObjects: Results<DeviceScanRealm>
    private let bag = DisposeBag()
    
    private let didFindSubject = PublishRelay<BTDevice>()
    private let didUpdateSubject = PublishRelay<BTDevice>()
    private let didReceive: Observable<BTDevice>
    private let timer: Observable<Int> = Observable.timer(.seconds(0), period: .seconds(1), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
    private var period: Observable<Void> {
        return BehaviorSubject<Void>(value: ())
    }
    
    init() {
        didReceive = Observable.merge(didFindSubject.asObservable(), didUpdateSubject.asObservable())
        scanObjects = realm.objects(DeviceScanRealm.self)
        scans = Observable.array(from: scanObjects)
            .map { scanned in
                return scanned.map { $0.toDeviceScan() }
            }
        bindScanning()
    }
    
    private func bindScanning() {
        bindPeriod()
        timer
            .subscribe(onNext: { [weak self] _ in
                self?.period.onCompleted()
            })
            .disposed(by: bag)
    }
    
    private func bindPeriod() {
        period
            .subscribe(onNext: {
                NSLog("YO onNext")
            }, onCompleted: { [weak self] in
                NSLog("YO onCompleted")
                self?.bindPeriod()
            })
            .disposed(by: bag)
    }
    
    private func scan(from device: BTDevice) -> DeviceScan {
        return DeviceScan(
            id: device.id,
            bluetoothIdentifier: device.bluetoothIdentifier.uuidString,
            buid: device.backendIdentifier ?? "Unknown",
            platform: device.platform,
            name: device.name ?? "Unknown",
            date: device.date,
            rssi: device.rssi
        )
    }
}

extension ScannerStore: BTScannerDelegate {

    func didFind(device: BTDevice) {
        didFindSubject.accept(device)
//        let updatedScans = scans.value + [scan(from: device)]
//        scans.accept(updatedScans)
    }

    func didUpdate(device: BTDevice) {
        didUpdateSubject.accept(device)
//        let scan = self.scan(from: device)
//        let updatedScans: [DeviceScan]
//        if let oldIndex = scans.value.firstIndex(where: { $0.id == device.id }) {
//            var updated = scans.value
//            updated[oldIndex] = scan
//            updatedScans = updated
//        } else {
//            updatedScans = scans.value + [scan]
//        }
//        scans.accept(updatedScans)
    }
}





//class ScannerStore: BTScannerStoreDelegate {
//
//    let scans: Observable<[DeviceScan]>
//    let storedScans = BehaviorRelay<[DeviceScan]>(value: [])
//
//    private let realm = try! Realm()
//    private var storedScansToken: NotificationToken!
//    private let scanObjects: Results<DeviceScanRealm>
//    private let bag = DisposeBag()
//
//    init() {
//        scanObjects = realm.objects(DeviceScanRealm.self)
//        scans = Observable.array(from: scanObjects)
//            .map { scanned in
//                return scanned.map { $0.toDeviceScan() }
//            }
//        bindRealm()
//        storedScansToken = realm.objects(DeviceScanRealm.self).observe { [weak self] _ in
//            guard let self = self else { return }
//            let scans: [DeviceScan] = self.realm.objects(DeviceScanRealm.self).map { $0.toDeviceScan() }
//            self.storedScans.accept(scans)
//       }
//    }
//
//    func didFind(device: CBPeripheral, rssi: Int) {
//        let scan = DeviceScan(
//            bluetoothIdentifier: device.identifier.uuidString,
//            buid: "",
//            platform: .iOS,
//            name: device.name ?? "Unknown",
//            date: Date(),
//            rssi: rssi
//        )
//        addDeviceToStorage(device: scan)
//    }
//
//    private func addDeviceToStorage(device: DeviceScan) {
//        let storageData = DeviceScanRealm(device: device)
//        try! realm.write {
//            realm.add(storageData, update: .all)
//        }
//        let updatedScans = scans.value + [device]
//        scans.accept(updatedScans)
//    }
    
//    private func bindRealm() {
//        Observable.array(from: scanObjects)
//            .map { scanned in
//                return scanned.map { $0.toDeviceScan() }
//        }
//        .subscribe(onNext: { scans in
//            print("Scans count: \(scans.count)")
//        })
//        .disposed(by: bag)
//    }
//}
