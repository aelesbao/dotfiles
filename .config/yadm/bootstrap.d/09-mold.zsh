#!/usr/bin/env zsh
#
# Mold Linker
#

if is-macos; then
  GROUP=admin
else
  GROUP=staff
fi

sudo mkdir -p /usr/local/{src,libexec}
sudo chown -R $(whoami):$GROUP /usr/local/{src,libexec}

git clone https://github.com/bluewhalesystems/sold /usr/local/src/sold
cd /usr/local/src/sold

cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=c++
cmake --build . -j $(nproc)
cmake --build . --target install

