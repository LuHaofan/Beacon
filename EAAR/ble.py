import asyncio
#import logging
from time import sleep
from bleak import discover
from bleak import BleakClient
import code
import socket
import time
import sys


server_ip = '127.0.0.1'
port = 12348
ts = time.time()
# Need to change to the address discovered by scan_ble.py
#address = "00:04:79:00:0B:DB" 
address = "00:04:79:00:0E:E6" 

esense_uuid_dict={\
    'model_num':"00002a00-0000-1000-8000-00805f9b34fb",\
    'imu_setup':"0000ff07-0000-1000-8000-00805f9b34fb",\
    'imu_read':"0000ff08-0000-1000-8000-00805f9b34fb",\
    'button_note':"0000ff09-0000-1000-8000-00805f9b34fb",\
}

# Please refer to esense BLE doc for IMU sampling rate configuration string
IMU_STOP = bytearray.fromhex('5302020000')
IMU_50 = bytearray.fromhex('5335020132')
# 10 Hz
#IMU_custom = bytearray.fromhex('530D02010A') 
# 30 Hz
IMU_custom = bytearray.fromhex('532102011E') 

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


async def run(address, loop, s, debug=False):
    async with BleakClient(address, loop=loop) as client:
        model_number = await client.read_gatt_char(esense_uuid_dict['model_num'])
        print("Model Number: {0}".format("".join(map(chr, model_number))), file=sys.stderr)

        imu = await client.read_gatt_char(esense_uuid_dict['imu_setup'])
        print("IMU_state: {0}".format(imu.hex()), file=sys.stderr)
        # update IMU states 
        await client.write_gatt_char(esense_uuid_dict['imu_setup'], IMU_custom, True)
        imu = await client.read_gatt_char(esense_uuid_dict['imu_setup'])
        #code.interact(local=locals())
        while imu != IMU_custom:
            await client.write_gatt_char(esense_uuid_dict['imu_setup'], IMU_custom, True)
            imu = await client.read_gatt_char(esense_uuid_dict['imu_setup'])
            print("IMU_state: {0}".format(imu.hex()))
            sleep(1)
        s.connect((server_ip, port))
        s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        def send_callback(sender, data):
        # For python3
            s.send(data);
            #print(data.hex())
        # For python2.7, socket could only send string, need to modify the server parser correspondingly.
        #   s.send(data.hex())
        imu_note = await client.start_notify(esense_uuid_dict['imu_read'],send_callback)
        but_note = await client.start_notify(esense_uuid_dict['button_note'],send_callback)
        input()
        await client.stop_notify(esense_uuid_dict['imu_read'])
        
# Comment this line if you don't want to save the connection log for debug
#logging.basicConfig(filename='test.log', level=logging.INFO)

loop = asyncio.get_event_loop()
loop.run_until_complete(run(address,loop,s,True))

