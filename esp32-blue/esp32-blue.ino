#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// https://www.uuidgenerator.net/

#define DEVICENAME "ESP32"

#define SEND "f2f9a4de-ef95-4fe1-9c2e-ab5ef6f0d6e9"
#define SEND_STRING "9e8fafe1-8966-4276-a3a3-d0b00269541e"

#define RECIVE "1450dbb0-e48c-4495-ae90-5ff53327ede4"
#define RECIVE_STRING "9393c756-78ea-4629-a53e-52fb10f9a63f"

bool deviceConnected = false;

String strToString(std::string str) {
  return str.c_str();
}

int strToInt(std::string str) {
  const char* encoded = str.c_str();
  return 256 * int(encoded[1]) + int(encoded[0]);
}

double intToDouble(int value, double max) {
  return (1.0 * value) / max;
}

bool intToBool(int value) {
  if (value == 0) {
    return false;
  }
  return true;
}

class ConnectionServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      Serial.println("Connected");
    };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false;
      Serial.println("Disconnected");
    }
};

class WriteString: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      String str = strToString(pCharacteristic->getValue());
      Serial.print("Recived String:");
      Serial.println(str);
    }
};

class WriteInt: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      int rint = strToInt(pCharacteristic->getValue());
      Serial.print("Recived Int:");
      Serial.println(rint);
    }
};

class WriteBool: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      bool rbool = intToBool(strToInt(pCharacteristic->getValue()));
      Serial.print("Recived Bool:");
      Serial.println(rbool ? "ON" : "OFF");
    }
};

BLECharacteristic *sSendInt;
BLECharacteristic *sSendBool;
BLECharacteristic *sSendString;

void deviceInit() {
  BLEDevice::init(DEVICENAME);
  BLEServer *btServer = BLEDevice::createServer();
  btServer->setCallbacks(new ConnectionServerCallbacks());

  BLEService *sRecive = btServer->createService(RECIVE);
  uint32_t cwrite = BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE;

  BLECharacteristic *sReciveString = sRecive->createCharacteristic(RECIVE_STRING, cwrite);
  sReciveString->setCallbacks(new WriteString());


  BLEService *sSend = btServer->createService(SEND);
  uint32_t cnotify = BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE  |
                     BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_INDICATE;

  sSendString = sSend->createCharacteristic(SEND_STRING, cnotify);
  sSendString->addDescriptor(new BLE2902());
  sSendString->setValue("Hi");

  sRecive->start();
  sSend->start();

  BLEAdvertising *pAdvertising = btServer->getAdvertising();
  pAdvertising->start();
  
}

void setup() {
  Serial.begin(115200);
  Serial.print("Device Name:");
  Serial.println(DEVICENAME);

  deviceInit();
}

uint32_t value = 0;
void loop() {
  delay(1000);
  if (deviceConnected) {

    sSendString->setValue("0x4d");
    sSendString->notify();

    value++;
  }
}
