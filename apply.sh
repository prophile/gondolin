#!/bin/bash
set -e
apt-get install puppet
puppet apply --modulepath modules manifests/gondolin.pp
