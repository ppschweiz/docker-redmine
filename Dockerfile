FROM sameersbn/redmine

RUN apt-get update && apt-get -y install libxapian-ruby1.9.1 xapian-omega libxapian-dev xpdf antiword unzip catdoc libwpd-0.9-9 libwps-0.2-2 gzip unrtf catdvi djview djview3 uuid uuid-dev
