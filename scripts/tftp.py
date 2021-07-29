#!/bin/python3

import tftpy

ip = input("Enter IP adress: ")
po = input("Enter Port: ")
port = int(po)

def main(ip,port):
  client = tftpy.TftpClient(ip, port)
  client.download("filename in server", "/tmp/filename", timeout=5)
  client.upload("filename to upload", "/local/path/file", timeout=5)

main(ip,port)
