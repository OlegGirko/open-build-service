include ../Makefile.include

INIT_SCRIPTS          := obssrcserver obsrepserver obsscheduler obsworker obspublisher obsdispatcher obssigner obswarden obsapidelayed obsapisetup obsstoragesetup obsservice obsdodup obsservicedispatch obsclouduploadserver obsclouduploadworker
LOGROTATE_CONFIGS     := obs-api obs-server obs-source_service
OBS_BIN_SCRIPTS       := obs_productconvert
OBS_SBIN_SCRIPTS      := obs_admin obs_serverstatus
SYSTEMD_SERVICE_FILES := obsdeltastore

UNITDIR=/usr/lib/systemd/system/

install: install_obsapisetup install_apache install_initscripts install_project_update install_logrotate install_fillups install_slp install_obs_bin install_devel_docs install_overview install_tests_appliance install_crontabs install_systemd_services install_registry_dirs

#install_overview

install_obsapisetup: system_dirs
	$(INSTALL) -m 755 obsapisetup $(DESTDIR)$(INITDDIR)/obsapisetup
	$(INSTALL) -m 755 setup-appliance.sh $(DESTDIR)$(OBS_BACKEND_PREFIX)/setup-appliance.sh
	sed -i \
	    -e 's|wwwrun\.www|$(APACHE_USER).$(APACHE_GROUP)|g' \
	    -e 's|/srv/www/obs/api|$(OBS_API_PREFIX)|g' \
	    -e 's|/srv/www/obs/overview|$(OBS_DOCUMENT_ROOT)/overview|g' \
	    -e 's|/srv/obs|$(OBS_BACKEND_DATA_DIR)|g' \
	    $(DESTDIR)$(INITDDIR)/obsapisetup \
	    $(DESTDIR)$(OBS_BACKEND_PREFIX)/setup-appliance.sh

install_apache:
	$(INSTALL) -d -m 755  $(DESTDIR)$(APACHE_CONIFGDIR_VHOST)
	$(INSTALL) -m 644 $(APACHE_VHOST_CONF) $(DESTDIR)$(APACHE_CONIFGDIR_VHOST)/obs.conf
	$(INSTALL) -m 644 $(APACHE_VHOST_CONTAINER_REGISTRY_CONF) $(DESTDIR)$(APACHE_CONIFGDIR_VHOST)/$(APACHE_VHOST_CONTAINER_REGISTRY_CONF)
	sed -i \
	    -e 's|/srv/www/obs/api|$(OBS_API_PREFIX)|g' \
	    -e 's|/srv/www/obs/overview|$(OBS_DOCUMENT_ROOT)/overview|g' \
	    -e 's|/srv/obs|$(OBS_BACKEND_DATA_DIR)|g' \
	    $(DESTDIR)$(APACHE_CONIFGDIR_VHOST)/$(APACHE_VHOST_CONTAINER_REGISTRY_CONF) \
	    $(DESTDIR)$(APACHE_CONIFGDIR_VHOST)/obs.conf

install_initscripts: system_dirs
	$(foreach script,$(INIT_SCRIPTS),$(shell $(INSTALL) -m 755 $(script) $(DESTDIR)$(INITDDIR)/$(script)) )
	$(foreach script,$(INIT_SCRIPTS),$(shell ln -sf $(INITDDIR)/$(script) $(DESTDIR)$(SBINDIR)/rc$(script)) )
	sed -i \
	    -e 's|wwwrun:www|$(APACHE_USER):$(APACHE_GROUP)|g' \
	    -e 's|/srv/www/obs/api|$(OBS_API_PREFIX)|g' \
	    -e 's|/srv/obs/log|$(OBS_BACKEND_LOG_DIR)|g' \
	    -e 's|/srv/obs|$(OBS_BACKEND_DATA_DIR)|g' \
	    -e 's|5352|$(OBS_SRCSERVER_PORT)|' \
	    -e 's|5252|$(OBS_REPOSERVER_PORT)|' \
	    -e 's|5152|$(OBS_SERVICESERVER_PORT)|' \
	    $(INIT_SCRIPTS:%=$(DESTDIR)$(INITDDIR)/%)

install_systemd_services: system_dirs
	$(foreach service,$(SYSTEMD_SERVICE_FILES),$(shell $(INSTALL) -m 644 ./systemd/$(service).service $(DESTDIR)$(UNITDIR)$(service).service) )
	$(foreach service,$(SYSTEMD_SERVICE_FILES),$(shell ln -sf /usr/sbin/service $(DESTDIR)/usr/sbin/rc$(service) ) )

install_project_update: system_dirs
	$(INSTALL) -m 0755 obs_project_update $(DESTDIR)$(SBINDIR)/obs_project_update


install_logrotate: system_dirs
	$(foreach config,$(LOGROTATE_CONFIGS),$(shell $(INSTALL) -m 644 $(config).logrotate $(DESTDIR)/etc/logrotate.d/$(config)) )
	sed -i \
	    -e 's| wwwrun www| $(APACHE_USER) $(APACHE_GROUP)|g' \
	    -e 's|/srv/www/obs/api|$(OBS_API_PREFIX)|g' \
	    -e 's|/srv/obs/log|$(OBS_BACKEND_LOG_DIR)|g' \
	    -e 's|/srv/obs|$(OBS_BACKEND_DATA_DIR)|g' \
	    $(LOGROTATE_CONFIGS:%=$(DESTDIR)/etc/logrotate.d/%)

install_fillups: system_dirs
	$(INSTALL) -m 0644 sysconfig.obs-server \
	    $(DESTDIR)$(OBS_FILLUP_DIR)/$(OBS_FILLUP_FILE)
	sed -i \
	    -e 's|/srv/obs/log|$(OBS_BACKEND_LOG_DIR)|g' \
	    -e 's|/srv/obs|$(OBS_BACKEND_DATA_DIR)|g' \
	    -e 's|5352|$(OBS_SRCSERVER_PORT)|' \
	    -e 's|5252|$(OBS_REPOSERVER_PORT)|' \
	    -e 's|5152|$(OBS_SERVICESERVER_PORT)|' \
	    $(DESTDIR)$(OBS_FILLUP_DIR)/$(OBS_FILLUP_FILE)

install_slp: system_dirs
	$(INSTALL) -m 644 obs.source_server.reg $(DESTDIR)/etc/slp.reg.d/
	$(INSTALL) -m 644 obs.repo_server.reg $(DESTDIR)/etc/slp.reg.d/
	sed -i \
	    -e 's|5352|$(OBS_SRCSERVER_PORT)|' \
	    -e 's|5252|$(OBS_REPOSERVER_PORT)|' \
	    $(DESTDIR)/etc/slp.reg.d/obs.source_server.reg \
	    $(DESTDIR)/etc/slp.reg.d/obs.repo_server.reg

install_obs_bin: system_dirs
	$(foreach script,$(OBS_BIN_SCRIPTS),$(shell $(INSTALL) -m 755 $(script) $(DESTDIR)$(BINDIR)/$(script)) )
	$(foreach script,$(OBS_SBIN_SCRIPTS),$(shell $(INSTALL) -m 755 $(script) $(DESTDIR)$(SBINDIR)/$(script)) )

install_crontabs:
	$(INSTALL) -m 644 cleanup_scm_cache.cron $(DESTDIR)/etc/cron.d/cleanup_scm_cache
	$(INSTALL) -m 644 obs_api_delayed_jobs_monitor.cron $(DESTDIR)/etc/cron.d/obs_api_delayed_jobs_monitor
	sed -i \
	    -e 's|/srv/www/obs/api|$(OBS_API_PREFIX)|g' \
	    -e 's|/srv/obs/service/log|$(OBS_BACKEND_LOG_DIR)|g' \
	    $(DESTDIR)/etc/cron.d/cleanup_scm_cache \
	    $(DESTDIR)/etc/cron.d/obs_api_delayed_jobs_monitor

system_dirs:
	$(INSTALL) -d -m 755 $(DESTDIR)$(OBS_BACKEND_PREFIX)
	$(INSTALL) -d -m 755 $(DESTDIR)$(INITDDIR)/
	$(INSTALL) -d -m 755 $(DESTDIR)/etc/logrotate.d/
	$(INSTALL) -d -m 755 $(DESTDIR)/etc/slp.reg.d/
	$(INSTALL) -d -m 755 $(DESTDIR)/etc/cron.d/
	$(INSTALL) -d -m 755 $(DESTDIR)$(BINDIR)/
	$(INSTALL) -d -m 755 $(DESTDIR)$(SBINDIR)/
	$(INSTALL) -d -m 755 $(DESTDIR)$(OBS_FILLUP_DIR)
	$(INSTALL) -d -m 755 $(DESTDIR)$(OBS_DEVEL_DOC_DIR)
	$(INSTALL) -d -m 755 $(DESTDIR)/usr/lib/obs/tests/appliance
	$(INSTALL) -d -m 755 $(DESTDIR)$(UNITDIR)

install_devel_docs:
	$(INSTALL) -m 644 README.devel $(DESTDIR)$(OBS_DEVEL_DOC_DIR)/README.devel

install_overview:
	$(INSTALL) -d -m 755 $(DESTDIR)$(OBS_DOCUMENT_ROOT)/overview
	$(INSTALL) -m 644 overview.html.TEMPLATE $(DESTDIR)$(OBS_DOCUMENT_ROOT)/overview

install_registry_dirs:
	mkdir -p $(DESTDIR)$(OBS_DOCUMENT_ROOT)/container-registry{,/log,/htdocs}

install_tests_appliance:
	cp -r ./t/*	$(DESTDIR)/usr/lib/obs/tests/appliance/
	find $(DESTDIR)/usr/lib/obs/tests/appliance -type f -print | \
	  xargs sed -i -e 's|/srv/obs|$(OBS_BACKEND_DATA_DIR)|g'

test_unit:
	INITDDIR=$(INITDDIR) SBINDIR=$(SBINDIR) prove -v t/*.t

test_system:
	INITDDIR=$(INITDDIR) SBINDIR=$(SBINDIR) prove -v t/*.ts

test_appliance:
	INITDDIR=$(INITDDIR) SBINDIR=$(SBINDIR) prove -v t/*.ta

.PHONY: test_unit test_system
