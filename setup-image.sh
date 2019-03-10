#!/bin/sh
set -eu

cd "$(dirname "$0")"

# Install runtime dependencies.
apk add --no-cache postgresql-libs ruby ruby-bigdecimal ruby-json ruby-bundler tzdata

# Install build-time dependencies.
apk add --no-cache --virtual .make build-base git postgresql-dev ruby-dev

# Install Ruby dependencies.
bundle install \
  --deployment \
	--frozen \
	--jobs=${JOBS:-2} \
	--no-cache \
	--without development test

# Fix ox gem.
cd vendor/bundle/ruby/*/extensions/*/*/ox-*
mkdir -p ox
ln -s ../ox.so ox/ox.so

cd -
cd vendor/bundle/ruby/*/

# Remove documentations and other unused textual files.
find gems/ -name 'doc' -type d -exec rm -frv '{}' +
find gems/ \( \
	-name 'README*' \
	-o -name 'CHANGELOG*' \
	-o -name 'CONTRIBUT*' \
  -o -name '*LICENSE*' \) -delete

# Remove sources and binaries of native extensions (they are installed
# in extensions directory).
find gems/ -type d -name ext -maxdepth 2 -exec rm -frv '{}' +
find gems/ -name '*.so' -delete

# Remove build logs and cache.
rm -rf cache
find extensions/ -name mkmf.log -delete

cd -

apk del .make

mkdir -p /opt/sirius
cp -ar .bundle bin app config db lib vendor config.ru Gemfile* Rakefile /opt/sirius/

# Lithos requires this file to exist to be able to mount host's
# resolv.conf over it.
printf '' > /etc/resolv.conf
