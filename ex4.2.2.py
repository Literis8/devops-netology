#!/usr/bin/env python3

import socket

from time import sleep

urls = {"drive.google.com": socket.gethostbyname("drive.google.com"),
        'mail.google.com': socket.gethostbyname("mail.google.com"), 'google.com': socket.gethostbyname("google.com")}
i = 0
while i < 50:  # для бесконечного цикла заменить i < 50 на 1 == 1...
    i += 1  # ...и закомментировать эту строчку
    for host in urls:
        sleep(5)
        if urls[host] != socket.gethostbyname(host):
            print("[ERROR] " + host + " IP mismatch: " + urls[host] + " " + socket.gethostbyname(host))
        urls[host] = socket.gethostbyname(host)
        print(host + " - " + urls[host])
