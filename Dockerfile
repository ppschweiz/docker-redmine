FROM redmine:5.1.5

ENV DMSF_VERSION 3.2.4

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
# fill up "database.yml" with bogus entries so the redmine Gemfile will pre-install all database adapter dependencies
# https://github.com/redmine/redmine/blob/e9f9767089a4e3efbd73c35fc55c5c7eb85dd7d3/Gemfile#L50-L79
	echo '# the following entries only exist to force `bundle install` to pre-install all database adapter dependencies -- they can be safely removed/ignored' > ./config/database.yml; \
	for adapter in mysql2 postgresql sqlserver sqlite3; do \
		echo "$adapter:" >> ./config/database.yml; \
		echo "  adapter: $adapter" >> ./config/database.yml; \
	done; \
# nokogiri's vendored libxml2 + libxslt do not build on mips64le, so use the apt packages when building
	gosu redmine bundle config build.nokogiri --use-system-libraries; \
	gosu redmine bundle install --jobs "$(nproc)"; \
	rm ./config/database.yml; \
# fix permissions for running as an arbitrary user
	chmod -R ugo=rwX Gemfile.lock "$GEM_HOME"; \
	rm -rf ~redmine/.bundle; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
