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


BASIC_BUILD_OPTS="\
--fail-on-missing \
--enable-shared \
--enable-soversion \
--enable-explicitlink \
"

ADDITIONAL_BUILD_OPTS="\
--enable-asimage \
--enable-astiff \
--enable-fftw3 \
--enable-gdml \
--enable-gsl-shared \
--enable-http \
--enable-mathmore \
--enable-minuit2 \
--enable-opengl \
--enable-python \
--enable-roofit \
--enable-ssl \
--enable-table \
--enable-tmva \
--enable-unuran \
--enable-xml \
--enable-xft \
\
--disable-afs \
--disable-alien \
--disable-bonjour \
--disable-builtin-afterimage \
--disable-builtin-freetype \
--disable-builtin-ftgl \
--disable-builtin-pcre \
--disable-builtin-zlib \
--disable-castor \
--disable-davix \
--disable-chirp \
--disable-dcache \
--disable-fitsio \
--disable-gfal \
--disable-globus \
--disable-krb5 \
--disable-ldap \
--disable-monalisa \
--disable-mysql \
--disable-odbc \
--disable-oracle \
--disable-pgsql \
--disable-pythia6 \
--disable-qt \
--disable-qtgsi \
--disable-rfio \
--disable-rpath \
--disable-ruby \
--disable-sapdb \
--disable-shadowpw \
--disable-sqlite \
--disable-srp \
--disable-xrootd \
"

DEFAULT_BUILD_OPTS=`echo ${BASIC_BUILD_OPTS} ${ADDITIONAL_BUILD_OPTS}`


FFTW3_PREFIX=$( (dirname $(dirname `which fftw-wisdom`)) 2> /dev/null )
if [ -n "${FFTW3_PREFIX}" ] ; then
	FFTW3_MODNAME=`. swmod.sh list "${FFTW3_PREFIX}" 2> /dev/null`
	if [ -n "${FFTW3_MODNAME}" ] ; then
		echo "FFTW3 loaded via swmod, will add ${FFTW3_MODNAME} to target package dependencies."

		DEFAULT_BUILD_OPTS="${DEFAULT_BUILD_OPTS} --with-fftw3-incdir=${FFTW3_PREFIX}/include"

		if \test -d "${FFTW3_PREFIX}/lib64" ; then
			DEFAULT_BUILD_OPTS="${DEFAULT_BUILD_OPTS} --with-fftw3-libdir=${FFTW3_PREFIX}/lib64"
		else
			DEFAULT_BUILD_OPTS="${DEFAULT_BUILD_OPTS} --with-fftw3-libdir=${FFTW3_PREFIX}/lib"
		fi
	fi
fi

swi_default_build_opts() {
	echo "${DEFAULT_BUILD_OPTS}"
}

swi_get_download_url () {
	echo "https://root.cern.ch/download/root_v${1}.source.tar.gz"
}

swi_get_version_no() {
	test -d .git && (git describe HEAD | sed 's/^v[ -_]\?//; s/^\([0-9]\+\)-\([0-9]\+\)-\([0-9]\+\)/\1.\2.\3/') || (cat build/version_number | sed 's|/|.|g')
}

swi_is_version_no() {
	echo "${1}" | grep -q '^[0-9]\+[.][0-9]\+[.][0-9]\+$'
}

swi_build_and_install() {
	export ROOTSYS="${SWMOD_INST_PREFIX}" \
	&& ./configure "$@" \
	&& make -j`. swmod.sh nthreads` \
	&& make install \
	&& echo '. "$SWMOD_PREFIX/bin/thisroot.sh"' > "${SWMOD_INST_PREFIX}/swmodrc.sh" \
	&& (test -n "${FFTW3_MODNAME}" && . swmod.sh add-deps "${FFTW3_MODNAME}" || true) \
	&& swi_add_bin_dep python
}
