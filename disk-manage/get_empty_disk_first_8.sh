#!/bin/bash
lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | egrep -o sd. | uniq -u | head -8
