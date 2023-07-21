

TECH_ROOT		?= $(IG_ROOT)/target/ihp13/pdk/ihp-sg13g2/

ig-setup-openroad:
	mkdir -p $(IG_ROOT)/target/ihp13/openroad/reports
	mkdir -p $(IG_ROOT)/target/ihp13/openroad/save

ig-openroad: ig-setup-openroad
	TECH_ROOT="$(TECH_ROOT)" \
	cd $(IG_ROOT)/target/ihp13/openroad && bash scripts/start.sh