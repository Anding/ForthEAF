#include <stdio.h>
#include "EAF_focuser.h"
#include <iostream>
#include <thread>
#include <chrono>
#include <string>
#include <cstring>
#include <iomanip>
#define EAF_AUTOCONNECT		"EAF Pro_90c92c"

int main() {
	BLE_DEVICE_INFO_T info[256];
	EAF_ERROR_CODE err;
	int count;
	int findFlag = 0;
	int Id1;
	EAF_SN eafsn;
	std::string gServerName1;
scan:
	err = EAFBLEScan(3000, info, 100, &count);
	if (err != EAF_SUCCESS) {
		std::cout << "EAF BLE Scan error!" << std::endl;
		return -1;
	}
	else {
		std::cout << "EAF BLE Scan get : " << count << std::endl;
		for (int i = 0; i < count; i++) {
			std::string name = std::string(info[i].name);
			if (!strncmp(name.c_str(), "EAF", 3))
			{
				std::cout << i << "  " << name << std::endl;
			}

			if (name == EAF_AUTOCONNECT)
			{
				findFlag = 1;
				break;

			}
		}
	}

	if (findFlag > 0) {
		gServerName1 = EAF_AUTOCONNECT;
	}
	else {
		goto scan;
	}

	err = EAFBLEConnect(gServerName1.c_str(), NULL, &Id1);
	if (err != EAF_SUCCESS) {
		std::cout << "EAFBLEConnect error!" << std::endl;
		return -1;
	}
	else {
		std::cout << "EAFBLEConnect Success! ID : " << Id1 << std::endl;
	}

	err = EAFBLEPair(Id1);
	if (err != EAF_SUCCESS) {
		std::cout << "EAFBLEPair failed, code :" << err << std::endl;
	}
	std::cout << "SDK Version : " << EAFGetSDKVersion() << std::endl;

	std::this_thread::sleep_for(std::chrono::seconds(1));

	err = EAFGetSerialNumber(Id1, &eafsn);
	if (err != EAF_SUCCESS) {
		std::cout << "EAF SN get Failed!" << std::endl;
	}
	std::cout << "SN : " << eafsn.id << std::endl;
	for (int i = 0; i < 8; i++) {
		std::cout << std::hex << std::setw(2) << std::setfill('0')
			<< (int)eafsn.id[i] << " ";
	}
	std::cout << std::endl;
	std::this_thread::sleep_for(std::chrono::seconds(1));
	int iStep = 20000;
	err = EAFMove(Id1, iStep);
	std::this_thread::sleep_for(std::chrono::seconds(5));
	err = EAFStop(Id1);
	std::this_thread::sleep_for(std::chrono::seconds(3));
	EAFBLEDisconnect(Id1);
	return 0;
}