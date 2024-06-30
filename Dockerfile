FROM redmine:5.0.9

ENV DMSF_VERSION 3.1.7

# Build and install DMSF plugin dependencies
# https://github.com/danmunn/redmine_dmsf#dependencies
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		antiword \
		catdoc \
		catdvi \
		djview \
		djview3 \
		gzip \
		unrtf \
		unzip \
		uuid \
		xapian-omega \
		xpdf \
	; \
	rm -rf /var/lib/apt/lists/*

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libwpd-dev \
		libwps-dev \
		libxapian-dev \
		make \
		uuid-dev \
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	gosu redmine bundle config --local without 'development test'; \
	gosu redmine bundle config --local set no-cache 'true'; \
	mkdir /usr/src/redmine/plugins/redmine_dmsf; \
	wget -O redmine_dmsf.tar.gz "https://github.com/danmunn/redmine_dmsf/archive/v${DMSF_VERSION}.tar.gz"; \
	tar -xf redmine_dmsf.tar.gz -C /usr/src/redmine/plugins/redmine_dmsf --strip-components=1; \
	rm redmine_dmsf.tar.gz; \
	chown -R redmine:redmine /usr/src/redmine/plugins/redmine_dmsf; \
# ensure the right database adapter is active in the Gemfile.lock
# install additional gems for Gemfile.local and plugins
	gosu redmine bundle check || gosu redmine bundle install --jobs "$(nproc)"; \
	rm -rf ~redmine/.bundle; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| grep -v '^/usr/local/' \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
