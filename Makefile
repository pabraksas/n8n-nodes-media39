.ONESHELL:
SHELL:=/usr/bin/bash
.DEFAULT_GOAL:=start

# #####################################################################################################################
# ###    Full path of the current script
#THIS=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0);
# ### The directory where current script resides
#DIR=$(dirname "${THIS}")
# ###
#PWD=$(pwd)
# ###
#

nullstring =

log_ok = @echo -e '\033[38;2;0;255;02m$1\033[0m'
log_cmd = @echo -e '\033[38;2;155;155;255m$1\033[0m'
log_inf = @echo -e '\033[38;2;100;100;250m$1\033[0m'
log_warning = @echo -e '\033[38;255;0;0;02m$1\033[0m'
log_err = @echo -e '\033[38;255;0;0;02m$1\033[0m'
log_achtung = @echo -e '\033[38;255;0;0;02m$1\033[0m'


#default:
#	@$(MAKE) -s help
#all: default

#@if [[ -f ".env" ]] ; then set -a; source .env; set +a; $(call log_inf, 'Loaded .env.local'); fi
#@if [[ -f ".env.local" ]] ; then set -a; source .env.local; set +a; $(call log_inf, 'Loaded .env.local'); fi
#: Load .env or .env.local if exists
init:
	@if [[ -f ".env" ]] ; then set -a; source .env; set +a; fi
	@if [[ -f ".env.local" ]] ; then set -a; source .env.local; set +a; fi


t: testim
#: Testim
testim:
	@echo -e "testim: $@ $#"

	pnpm start --characters="./characters/tg-character.json"
	#pnpm start --characters="./characters/eliza.character.json"
	#pnpm start --characters="./characters/c3po.character.json"

h: help
#: Help and Commands list
help: init
	$(call log_ok, 'Commands:')
	grep -B1 -E "^[a-zA-Z0-9_-]+\:([^\=]|$$)" Makefile \
	| grep -v -- -- \
	| sed 'N;s/\n/###/' \
	| sed -n 's/^#: \(.*\)###\(.*\):.*/\2:###\1/p' \
	| column -t  -s '###'

	__INTERACTIVE=""
	if [ -t 1 ]; then
		__INTERACTIVE="1"
	fi


#: Check runing at root
isudoer:
	if [[ $UID != 0 ]]; then
		@echo "Please run this script with sudo:"
		@echo -e "sudo $0 $*"
		@exit 1
	fi


set: setup
#: Setuping
setup: init
	@echo "============================================="
	@echo "               -= Setuping =-                "
	@echo "============================================="
	#	npm install pnpm@latest -g
	#	npm install yarn -g
	#	npm install pm2 -g

	@$(MAKE) clean

	pnpm i

	@$(MAKE) build
	@$(MAKE) start


clear: clean
#: Remove files and folders
clean: init
	@echo "============================================="
	@echo "               -= Cleaning =-                 "
	@echo "============================================="

	# ### Find and remove node_modules directories, dist directories.
	find . -type d -name "node_modules" -exec rm -rf {} + -o -type d -name "dist" -exec rm -rf {}
	rm -rf `find . -type d -name dist`
	rm -rf `find . -type d -name node_modules`
	#
	rm -rf `find . -type d -name .cache`
	rm -rf `find . -type d -name .next`
	rm -rf `find . -type d -name .turbo`
	#
	rm -rf `find . -type d -name build`
	rm -rf `find . -type d -name _build`
	#
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	#
	rm -f `find . -type f -name 'yarn.lock' ` >/dev/null 2>&1
	rm -f `find . -type f -name 'package-lock.json' `  >/dev/null 2>&1


d: down
#: Down
down: init
	@echo "============================================="
	@echo "               -= Down =-"
	@echo "============================================="

	# @docker compose -f ./packages/docker/compose.yml down -v


s: start
#: Starting
start: init
	@echo "============================================="
	@echo "               -= Starting =-"
	@echo "============================================="
	#	docker compose -f ./packages/docker/compose.yml up -d --build --force-recreate

	# pnpm start
	# pnpm start --character=./characters/vcorp.character.json
	pnpm start --character=./characters/c3po.character.json


b: build

#: Building
build: init
	@echo "============================================="
	@echo "               -= Building =-"
	@echo "============================================="

	pnpm build
	# turbo build

	# @$(MAKE) -s build-images


bi: build-images

#: Build images
build-images: init
	@$(call log_ok, '	Docker build images start !')
	set DOCKER_BUILDKIT=1
	# set BUILDKIT_INLINE_CACHE=1

	docker build --tag s3app-server --file ./packages/docker/Dockerfile.s3app-server ./apps/s3app-server/
	docker build --tag s3app-web-panel --file ./packages/docker/Dockerfile.s3app-web-panel ./apps/s3app-web-panel/

	docker build --tag s3app-bot --file ./packages/docker/Dockerfile.s3app-bot ./apps/s3app-bot/

	#@docker build --tag s3app-license-repository --file ./packages/docker/Dockerfile.s3app-license-repository ./apps/s3app-license-repository/
	#@docker build --tag s3app-license-repository-web-panel --file ./packages/docker/Dockerfile.s3app-license-repository-web-panel ./apps/s3app-license-repository-web-panel/


#: Remove all docker containers and images
prune:
	$(call log_ok, '	Docker system prune !')
	docker system prune --all --force  --volumes
	# command will remove all docker images:
	#@docker rmi --force $(docker images --all --quiet)



nw: network-reset
#: Reset NetworkManager
network-reset:
	sudo systemctl restart NetworkManager --force


cmd:
	@echo $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
