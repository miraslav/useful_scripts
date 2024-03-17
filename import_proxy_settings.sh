#!/bin/bash
for proxy in http_proxy https_proxy ; do export "$proxy"=http://10.8.54.68:9090; done
