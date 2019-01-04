FROM sameersbn/redmine:3.3.7

# Install DMSF plugin dependencies
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
		libwpd-0.9-9 \
		libwps-0.2-2 \
		libxapian-dev \
		libxapian-ruby1.9.1 \
		unrtf \
		unzip \
		uuid \
		uuid-dev \
		xapian-omega \
		xpdf \
	; \
	rm -rf /var/lib/apt/lists/*
