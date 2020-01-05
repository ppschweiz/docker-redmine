FROM sameersbn/redmine:3.4.13

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
		libwpd-0.10-10 \
		libwps-0.4-4 \
		libxapian-dev \
		ruby-xapian \
		unrtf \
		unzip \
		uuid \
		uuid-dev \
		xapian-omega \
		xpdf \
	; \
	rm -rf /var/lib/apt/lists/*
