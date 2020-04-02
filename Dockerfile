FROM redmine:3.4.13

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
		gcc \
		gzip \
		libwpd-0.10-10 \
		libwps-0.4-4 \
		libxapian-dev \
		make \
		unrtf \
		unzip \
		uuid \
		uuid-dev \
		xapian-omega \
		xpdf \
	; \
	rm -rf /var/lib/apt/lists/*
