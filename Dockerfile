FROM sameersbn/redmine:3.3.7

# Install DMSF plugin dependencies
# https://github.com/danmunn/redmine_dmsf#dependencies
RUN set -ex; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libxapian-ruby1.9.1 \
		xapian-omega \
		libxapian-dev \
		xpdf \
		antiword \
		unzip \
		catdoc \
		libwpd-0.9-9 \
		libwps-0.2-2 \
		gzip \
		unrtf \
		catdvi \
		djview \
		djview3 \
		uuid \
		uuid-dev \
	; \
	rm -rf /var/lib/apt/lists/*
