# Copyright (C) 2015 Oliver Schulz <oliver.schulz@tu-dortmund.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


DEFAULT_BUILD_OPTS="\
--build=x86_64-linux-gnu \
--disable-werror \
--enable-checking=release \
--enable-languages=c,c++,fortran,objc,obj-c++ \
--enable-libstdcxx-time=yes \
--enable-linker-build-id \
--enable-objc-gc \
--enable-shared \
--enable-threads=posix \
--host=x86_64-linux-gnu \
--target=x86_64-linux-gnu \
--with-system-zlib \
--with-tune=generic \
"

# Inherit enable/disable gnu-unique-object from current GCC:
DEFAULT_BUILD_OPTS="${DEFAULT_BUILD_OPTS} "`gcc -v 2>&1 |grep -o '[-]-\(enable\|disable\)-gnu-unique-object' 2>/dev/null | tail -n 1`

swi_default_build_opts() {
	echo "${DEFAULT_BUILD_OPTS}"
}

swi_get_download_url () {
	echo "http://ftpmirror.gnu.org/gcc/gcc-${1}/gcc-${1}.tar.bz2"
}

swi_get_version_no() {
	cat gcc/BASE-VER
}

swi_is_version_no() {
	echo "${1}" | grep -q '^[0-9]\+[.][0-9]\+[.][0-9]\+$'
}

swi_build_and_install() {
	(test ! -e "gmp" -o ! -e "mpc" -o ! -e "mpfr" && ./contrib/download_prerequisites || true) \
	&& local src_dir=`pwd` \
	&& local build_dir="../"`basename "${src_dir}"`_build_"`. swmod.sh hostspec`" \
	&& mkdir "${build_dir}" \
	&& cd "${build_dir}" \
	&& . swmod.sh "${src_dir}"/configure "$@" \
	&& make -j`. swmod.sh nthreads` \
	&& make install \
	&& swi_add_bin_dep as
}
