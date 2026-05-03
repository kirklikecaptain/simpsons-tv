PI ?= kirk
USERNAME = pi
APP_DIR ?= ~/simpsons-tv
HOSTNAME ?= $(PI)s-pi-tv.local
DEVICE ?= $(USERNAME)@$(HOSTNAME)
DESTINATION = $(DEVICE):$(APP_DIR)

.PHONY: sync sync-media init-pi

init-pi:
	ssh $(DEVICE) "mkdir -p $(APP_DIR)"
	$(MAKE) sync
	ssh -t $(DEVICE) "bash $(APP_DIR)/pi/init.sh"

sync:
	rsync -rltvz --filter=':- .gitignore' --exclude='.git/' ./ $(DESTINATION)

sync-media:
	rsync -rltvz ./media/ $(DESTINATION)/media/
