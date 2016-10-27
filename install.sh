#!/bin/bash

basename=$(cd `dirname $0`; pwd)

echo "$basename"

sudo apt-get install m4 build-essential pkg-config devhelp libglib2.0-doc libgtk2.0-doc glade libglade2-dev libgtk2.0* openssl libssl-dev -y

if [ $? -ne 0 ]; then
	echo "[ERROR] apt-get install failed"
	exit 1
fi

cd $basename

install_cmake()
{
	echo "[INFO] install cmake"
	cd $basename
	tar -xzvf cmake-3.0.2.tar.gz
	cd cmake-3.0.2
	./bootstrap
	if [ $? -ne 0 ]; then
        	echo "[ERROR] configure cmake failed"
        	exit 1
	fi
	make
	if [ $? -ne 0 ]; then
        	echo "[ERROR] make cmake failed"
        	exit 1
	fi
	sudo make install
	if [ $? -ne 0 ]; then
        	echo "[ERROR] install cmake failed"
        	exit 1
	fi
}

install_gmp()
{
	echo "[INFO] install gmp"
	cd $basename
	tar -xjvf gmp-6.0.0a.tar.bz2
	cd gmp-6.0.0/
	./configure
	if [ $? -ne 0 ]; then
        	echo "[ERROR] configure gmp failed"
        	exit 1
	fi
	make
	if [ $? -ne 0 ]; then
        	echo "[ERROR] make gmp failed"
        	exit 1
	fi
	sudo make install
	if [ $? -ne 0 ]; then
        	echo "[ERROR] install gmp failed"
        	exit 1
	fi
}

install_tpm()
{
	echo "[INFO] install tpm"
	cd $basename/tpm-emulator
	sh build.sh
	if [ $? -ne 0 ]; then
        	echo "[ERROR] build tpm failed"
                exit 1
        fi
	cd build/
	sudo make install
	if [ $? -ne 0 ]; then
        	echo "[ERROR] make install tpm failed"
                exit 1
        fi
}

init_tpm()
{
	echo "[INFO] init tpm"
	cd $basename/tpm-emulator
	tpmd deactivated
	killall tpmd
	tpmd clear
	depmod -a
	modprobe tpmd_dev	
	if [ $? -ne 0 ]; then
        	echo "[ERROR] modprobe tpmd_dev failed"
                exit 1
        fi

}

install_trousers()
{
	echo "[INFO] install trousers"
	cd $basename
	tar -xzvf trousers-0.3.13.tar.gz
	cd trousers-0.3.13

	#sed -i "s%\${top_builddir}/src/tddl/libtddl.a%/usr/local/lib/libtddl.so%g" src/tcsd/Makefile.am
	#sed -i "s%\${top_builddir}/src/tddl/libtddl.a%/usr/local/lib/libtddl.so%g" src/tcsd/Makefile.in
	
	cp $basename/replace-files/ps_utils.c	src/tcs/ps
	cp $basename/replace-files/tspps.h	src/include

	echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/tddl.conf
	sudo ldconfig
	
	./configure
	if [ $? -ne 0 ]; then
        echo "[ERROR] configure trousers failed"
                exit 1
        fi
	make
	if [ $? -ne 0 ]; then
        echo "[ERROR] make trousers failed"
                exit 1
        fi
	sudo make install
	if [ $? -ne 0 ]; then
        echo "[ERROR] make install trousers failed"
                exit 1
        fi
}

install_tpm_tools()
{
	echo "[INFO] install tpm-tools"
	cd $basename
	tar -xzvf tpm-tools-1.3.8.tar.gz
	cd tpm-tools-1.3.8
	./configure
        if [ $? -ne 0 ]; then
        echo "[ERROR] configure tpm-tools failed"
                exit 1
        fi
        make
        if [ $? -ne 0 ]; then
        echo "[ERROR] make tpm-tools failed"
                exit 1
        fi
        sudo make install
        if [ $? -ne 0 ]; then
        echo "[ERROR] make install tpm-tools failed"
                exit 1
        fi

}

ret=$(cmake --version | grep 3.0.2 | wc -l)
if [ "$ret" -eq "0" ]; then
	install_cmake
	install_gmp
fi

ret=$(which tpmd | wc -l)
if [ "$ret" -eq "0" ]; then
	install_tpm
	init_tpm
fi

ret=$(which tcsd | wc -l)
if [ "$ret" -eq "0" ]; then
	install_trousers
fi

#ret=$(which tpm_version | wc -l)
#if [ "$ret" -eq "0" ]; then
#	install_tpm_tools
#fi

echo "[INFO] done!"
