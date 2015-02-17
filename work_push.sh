#!/bin/bash

export http_proxy=http://proxy-jf.intel.com:911;
export https_proxy=https://proxy-jf.intel.com:912;

git remote set-url origin https://Combustible@github.com/Combustible/configscripts.git
git remote set-url --push origin https://Combustible@github.com/Combustible/configscripts.git

git push
