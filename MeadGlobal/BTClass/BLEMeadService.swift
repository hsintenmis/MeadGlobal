//
// 藍芽 BLE 檢測儀, 測試使用藍牙 BLE HC-08模組
// D_DEVNAME = "HTEBT401", "HC-08", "%MEAD%"
// Service :0000ffe0-0000-1000-8000-00805f9b34fb
// chart   :0000ffe1-0000-1000-8000-00805f9b34fb (w/n)
//
// 藍牙 BLE 必填標準參數 (iOS不用處理)
// 關閉或打開通知(Notify)的UUID, 藍牙規格固定值
// NOTIFY = "00002902-0000-1000-8000-00805f9b34fb" (Descriptor)
//

import CoreBluetooth
import Foundation

/**
 * protocol: BLEMeadServiceDelegate
 */
protocol BLEMeadServiceDelegate {
    func handlerBLEMeadService(mBLEMeadService: BLEMeadService, identCode: String!, result: Bool!, msgCode: String!)
}

/**
 * 藍芽 BLE 檢測儀
 */
class BLEMeadService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private let IS_DEBUG = false
    
    // protocol BLEMeadServiceDelegate
    var mBLEMeadServiceDelegate: BLEMeadServiceDelegate?
    
    // 藍芽裝置名稱
    private let aryBTNAME = ["HC-08", "HTEBT401", "=EMD00401"]
    
    // UUID, Service, Char
    private let UID_SERV: CBUUID = CBUUID(string: "0000ffe0-0000-1000-8000-00805f9b34fb")
    private let UID_CHAR_W: CBUUID = CBUUID(string: "00002902-0000-1000-8000-00805f9b34fb")
    private let UID_CHAR_I: CBUUID = CBUUID(string: "0000ffe1-0000-1000-8000-00805f9b34fb")
    
    // BLE 設備，Center service 設定
    private var activeTimer:NSTimer!
    private var centralManager:CBCentralManager!
    private var connectingPeripheral: CBPeripheral!
    
    // 主要的 Chanel 與 Characteristic
    private var mBTService: CBService!
    private var mBTCharact_W: CBCharacteristic!
    private var mBTCharact_I: CBCharacteristic!
    
    // 藍芽設備狀態
    private var BT_POWERON = false
    private var BT_ISREADYFOTESTING = false
    
    // 其他 class, property
    private var pubClass: PubClass!
    private var mTimer: NSTimer!
    
    /**
    * init
    */
    override init() {
        super.init()
    }
    
    /**
     * 藍芽設備初始與連接
     */
    func startUpCentralManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /**
     * 開始掃描搜索 BT 設備
     */
    func StartScanDev() {
        centralManager.scanForPeripheralsWithServices(nil, options: nil)
    }

    /**
    * 停止掃描 BT 設備
    */
    func StopScanDev() {
        self.centralManager.stopScan()
        mTimer.invalidate()
        mTimer = nil
        
        // 設定 'handler': 掃描 BT 設備
        setHandlerData(Flag: "BT_statu", Result: true, Msg: "bt_searchingstop")
    }
    
    /**
    * 設定 'dictHanlder' value
    *
    * @param Flag : BT代碼, ex. 'BT_statu'
    * @param Result : 執行結果, ex. 'Y' or 'N'
    * @param Msg : 訊息代碼, ex. 'bt_powered_on'
    */
    private func setHandlerData(Flag flag: String!, Result rs: Bool!, Msg msg: String!) {
        mBLEMeadServiceDelegate?.handlerBLEMeadService(self, identCode: flag, result: rs, msgCode: msg)
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 開始探索 BLE 周邊裝置
     * On detecting a device, will get a call back to "didDiscoverPeripheral"
     * @param RSSI: 訊號強度
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        if (IS_DEBUG) { print("Discovered: \(peripheral.name)") }
        
        // 設定 'handler': 掃描 BT 設備
        setHandlerData(Flag: "BT_statu", Result: true, Msg: "bt_searching")
        
        // 搜索掃描時間限制 5 秒
        mTimer = NSTimer(timeInterval: 5.0, target: self, selector: "findBTNameDev:", userInfo: peripheral, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(mTimer, forMode: NSRunLoopCommonModes)
    }
    
    /**
    * 尋找指定藍芽名稱的 Device
    * @ param timer: Selector 的 '本體'
    */
    func findBTNameDev(timer: NSTimer) {
        if (BT_ISREADYFOTESTING == true) {
            return
        }
        
        let peripheral = timer.userInfo as! CBPeripheral
        for strBTName in aryBTNAME {
            if (peripheral.name == strBTName) {
                self.connectingPeripheral = peripheral
                self.centralManager.stopScan()
                self.centralManager.connectPeripheral(peripheral, options: nil)
                
                // 設定 'handler': 找到指定名稱的藍芽設備
                setHandlerData(Flag: "BT_statu", Result: true, Msg: "bt_founddev")

                return
            }
        }
        
        // 設定 'handler': 找不到指定名稱的藍芽設備
        setHandlerData(Flag: "BT_statu", Result: false, Msg: "bt_cantfindbtdevice")
        
        return
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 指定的藍芽設備找到後，開始執行設備連結
     * 可以在此設定 Peripheral Delegate
     */
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.connectingPeripheral.delegate = self
        
        // 設定 'handler': 顯示 '藍芽設備初始'
        setHandlerData(Flag: "BT_statu", Result: true, Msg: "bt_initing")
        
        // 尋找指定的 Service UID
        self.connectingPeripheral.discoverServices([UID_SERV])
        
        // 搜尋全部的 Service
        //self.connectingPeripheral.discoverServices(nil)
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * Delegate, CBCentralManagerDelegate
     * BLE 斷線
     */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        BT_ISREADYFOTESTING = false
        
        // 設定 Hanlder
        setHandlerData(Flag: "BT_conn", Result: false, Msg: "bt_connect_break")
    }
    
    /**
     * #mark: CBCentralManagerDelegate
     * 目前 BLE center manage statu
     */
    func centralManagerDidUpdateState(central: CBCentralManager) {
        var msg = ""
        switch (central.state) {
        case .PoweredOff:
            msg = "bt_mobile_off"
            print(msg)
            BT_POWERON = false
            BT_ISREADYFOTESTING = false
            
        case .PoweredOn:
            msg = "bt_mobile_on"
            BT_POWERON = true
            self.StartScanDev()
            
        case .Resetting:
            msg = "bt_mobile_resetting"
            
        case .Unauthorized:
            msg = "bt_mobile_unauthorized"
            
        case .Unknown:
            msg = "bt_mobile_unknown_stat"
            
        case .Unsupported:
            msg = "bt_mobile_unsupported"
        }
        
        if (IS_DEBUG) { print(msg) }
        
        // 設定 'handler': 藍芽設備狀況
        setHandlerData(Flag: "BT_statu", Result: true, Msg: msg)
    }
    
    /**
     * #mark: CBPeripheralDelegate
     * 查詢藍芽設備的 Service channel
     * Service 查詢到後，可以在查詢該 Service 下的 'Characteristics'
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?)
    {
        // 指定的 Service channel 查詢 character code
        
        // loop Service UUID, 設定指定 UUID 的 channel
        for tmpCBService in peripheral.services! {
            if (IS_DEBUG) {
                print("Serv UID: \(tmpCBService.UUID)")  // 顯示 'Blood Pressure'
                print("Serv UID: \(tmpCBService.UUID.UUIDString)\n") // 顯示 '1810'
            }
            
            if (tmpCBService.UUID == UID_SERV) {
                self.mBTService = tmpCBService
                
                if (IS_DEBUG) { print("Main Serv UID: \(self.mBTService.UUID)\n") }
            }
            
            // 指定的 Service, 查詢全部的 Chart
            peripheral.discoverCharacteristics(nil, forService: tmpCBService)
        }
        
        // 指定的 Service, 查詢指定的 Chart UUID 執行測試連接
        //peripheral.discoverCharacteristics([UID_CHAR_W], forService: self.mBTService)
    }
    
    /**
     * #mark: CBPeripheralDelegate
     * 查詢指定 Service channel 的 charccter code
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // 指定的 service channel,loop charact UUID 設定 Test/Write charact
        for mChart in service.characteristics! {
            if (IS_DEBUG) { print("Char UID: \(mChart.UUID)\n") }
            
            // 設定 'Indenify' Chart
            if (mChart.UUID == UID_CHAR_I) {
                self.mBTCharact_I = mChart
                
                // 直接執行關閉或打開通知(Notify)的UUID, 若狀態改變會執行
                // NotificationStateForCharacteristic statu 更新
                peripheral.setNotifyValue(true, forCharacteristic: mChart)
                
                if (IS_DEBUG) {
                    print("SetNotify_Chart_UID:\(mChart.UUID)")
                    print("Chart_IsNotify: \(mChart.isNotifying)\n")
                }
            }
                
                // 設定 '寫入' Chart
            else if (mChart.UUID == UID_CHAR_W) {
                self.mBTCharact_W = mChart
            }
        }
        
        //if (IS_DEBUG) { peripheral.discoverDescriptorsForCharacteristic(mChart) }
    }
    
    /**
     * #mark: CBPeripheralDelegate
     * NotificationStateForCharacteristic statu 更新
     */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (IS_DEBUG) {
            print("Notfy Recv, UID: \(characteristic.UUID)")
            print("Val: \(characteristic.value)")
            print("Notify: \(characteristic.isNotifying)\n")
        }
        
        // 藍芽是否連接與初始成功，測量值主 service 的 notify chart
        if (characteristic.isNotifying == true && characteristic.UUID == UID_CHAR_I) {
            BT_ISREADYFOTESTING = true
            
            // 設定 hanlder
            setHandlerData(Flag: "BT_conn", Result: true, Msg: "bt_readytesting")
            
            return
        }
    }
    
    /**
     * #mark: CBPeripheralDelegate
     * 目前未用，主要是各 service, chart 的'描述說明'
     * Discover characteristics 的 DiscoverDescriptors
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if (IS_DEBUG) {
            print("Despt of Chart : \(characteristic.UUID)")
            
            if (characteristic.descriptors?.count > 0) {
                for tmpDispt in characteristic.descriptors! {
                    print("Despt: \(tmpDispt.UUID)")
                    print("Despt: \(tmpDispt.value)\n")
                }
            }
        }
        
        // TODO
        if (IS_DEBUG) {
            let mDisp: CBDescriptor = characteristic.descriptors![0]
            print("BTDEF_NOTIFY: \(mDisp)")
        }
    }
    
    /**
     * #mark: CBPeripheralDelegate
     * BT 有資料更新，傳送到本機 BT 顯示
     * 主 Service 數值回傳：連續的 'byte' value
     */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        let mNSData = characteristic.value!
        //print("Update MainSrv val : \(characteristic.value)\n")
        
        dispatch_async(dispatch_get_main_queue(), {
            var mIntVal = [UInt8](count:mNSData.length, repeatedValue:0)
            mNSData.getBytes(&mIntVal, length:mNSData.length)
            self.analyRespon(mIntVal)
        })
        
        // 接收與回傳數值至 行動裝置
        /*
        if (characteristic.value?.length > 0 && characteristic.UUID == UID_CHAR_I) {
            let mNSData = characteristic.value!
            
            if (IS_DEBUG) { print("Update MainSrv val : \(mNSData)\n") }
            
            // 取得回傳資料，格式如: HEX: 01 00 23 A0 02 ..., [Byte] = [UInt8]
            var mIntVal = [UInt8](count:mNSData.length, repeatedValue:0)
            mNSData.getBytes(&mIntVal, length:mNSData.length)
            
            if (IS_DEBUG) { print(mIntVal) }
            
            self.analyRespon(mIntVal)
            
            return
        }
        */
    }
    
    /**
     * 將傳回的 bit array , 一個一個拆解並回傳至 hanlder
     */
    private func analyRespon(aryRS: Array<UInt8>) {
        if (aryRS.count < 1) {
            return
        }
        
        for intVal in aryRS {
            // 通知上層 class 'BTScaleMain' 執行頁面更新
            setHandlerData(Flag: "BT_data", Result: true, Msg: String(intVal))
        }
    }
    
    /**
     * BT 執行連接程序
     */
    func BTConnStart() {
        if (BT_ISREADYFOTESTING != true) {
            startUpCentralManager()
        }
    }
    
    /**
     * BT 斷開連接
     */
    func BTDisconn() {
        if (BT_ISREADYFOTESTING != true) {
            activeTimer = nil
            connectingPeripheral = nil
            mBTCharact_W = nil
            mBTCharact_I = nil
            mBTService = nil
            
            return
        }
        
        if activeTimer != nil {
            activeTimer.invalidate()
            activeTimer = nil
        }
        
        centralManager.cancelPeripheralConnection(connectingPeripheral)
        connectingPeripheral = nil
        mBTCharact_W = nil
        mBTCharact_I = nil
        mBTService = nil
        
        if (IS_DEBUG) {print("BT disconnect...")}
    }
    
    /**
     * !! NO USE !!
     * 寫入(傳送)資料至 remote BT
     */
    func BTWriteData() {
        var aryData: Array<UInt8> = [0x14];
        let mNSData = NSData(bytes: &aryData, length: (aryData.count))
        print(mNSData)
        
        // 寫入資料傳送至 remote BT
        self.connectingPeripheral.writeValue(mNSData, forCharacteristic: self.mBTCharact_W, type: CBCharacteristicWriteType.WithoutResponse)
        
        return
    }
    
}