#!/bin/bash
for user in user1, user2, user3; do usermod -a -G yourgroup "$user"; done
