sudo gem install bundler
sudo apt install ruby-dev
sudo apt install tk8.5-dev
sudo ln -sf /usr/lib/x86_64-linux-gnu/tcl8.5/tclConfig.sh /usr/lib/tclConfig.sh
sudo ln -sf /usr/lib/x86_64-linux-gnu/tk8.5/tkConfig.sh /usr/lib/tkConfig.sh
sudo ln -sf /usr/lib/x86_64-linux-gnu/libtcl8.5.so.0 /usr/lib/libtcl8.5.so.0
sudo ln -sf /usr/lib/x86_64-linux-gnu/libtk8.5.so.0 /usr/lib/libtk8.5.so.0

#
bundle install
