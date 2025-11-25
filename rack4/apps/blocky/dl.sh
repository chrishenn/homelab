#!/bin/bash

lists="/mnt/k/docker/blocky/blacklists"
curl -L https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -o "$lists/hosts"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/pro.plus.txt -o "$lists/pro.plus.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/fake.txt -o "$lists/fake.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/popupads.txt -o "$lists/popupads.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/tif.txt -o "$lists/tif.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/native.samsung.txt -o "$lists/native.samsung.txt"
curl -L https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard/native.winoffice.txt -o "$lists/native.winoffice.txt"
