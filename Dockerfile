FROM sameersbn/redmine:3.1-latest

RUN apt-get update && apt-get -y install libxapian-ruby1.9.1 xapian-omega libxapian-dev xpdf antiword unzip catdoc libwpd-0.9-9 libwps-0.2-2 gzip unrtf catdvi djview djview3 uuid uuid-dev

# fix for dmsf
rm -rf ${REDMINE_INSTALL_DIR}/files
ln -sf ${REDMINE_DATA_DIR}/files ${REDMINE_INSTALL_DIR}/files
