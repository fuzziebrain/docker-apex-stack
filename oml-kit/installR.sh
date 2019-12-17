#!/bin/bash

# Run as root

CRAN_MIRROR_URL=${CRAN_MIRROR_URL:-https://cran.r-project.org}
R_HOME=/usr/lib64/R

yum-config-manager --enable ol7_optional_latest ol7_addons

yum install -y \
    make \
    automake \
    gcc \
    gcc-c++ \
    pango-devel \
    libXt-devel \
    libpng12 \
    unzip \
    R-3.3.0-2.el7

rm -rf /var/cache/yum

mkdir /usr/share/doc/R-$(rpm -q R.x86_64 --queryformat '%{VERSION}')/html

cat << EOF > $R_HOME/etc/Rprofile.site
local({
  r <- getOption("repos")
  r["CRAN"] <- "${CRAN_MIRROR_URL}"
  options(repos = r)
})
EOF

rm -rf /tmp/hsperfdata_root