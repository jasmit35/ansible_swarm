#
.SILENT:
#
#==========================================================================================
#  Standard playbook stuff 
#==========================================================================================
.PHONY: yaml-lint
yaml-lint:
	printf "\n🚀    Performing yaml linting on ${PLAYBOOK}...\n"
	yamllint ${PLAYBOOK}; \
	if [ $$? -eq 0 ]; \
	then \
		printf "      yaml linting successful!\n"; \
	fi

.PHONY: syntax-check
syntax-check:
	printf "\n🚀    Performing syntax check on ${PLAYBOOK}...\n"
	ansible-playbook --syntax-check ${PLAYBOOK} --extra-vars "HOSTS=${HOSTS}" 
	if [ $$? -eq 0 ]; \
	then \
		printf "      syntax check successful!\n"; \
	fi

.PHONY: ansible-lint
ansible-lint:
	printf "\n🚀    Performing ansible linting...\n"
	/opt/homebrew/bin/ansible-lint ${PLAYBOOK}
	if [ $$? -eq 0 ]; \
	then \
		printf "      ansible linting successful!\n"; \
	fi

check: yaml-lint syntax-check ansible-lint

#==========================================================================================

run-in-devl: ## Run playbook in devl; requires PLAYBOOK
	ansible-playbook -i inventory/devl_swarm.yaml --ask-become-pass ${PLAYBOOK}

run-in-test: ## Run playbook in test; requires PLAYBOOK
	ansible-playbook -i inventory/test_swarm.yaml --ask-become-pass ${PLAYBOOK}

run-in-prod: 
	ansible-playbook -i inventory/prod_swarm.yaml --ask-become-pass ${PLAYBOOK}

#==========================================================================================
#  Swarm management
#==========================================================================================

.PHONY: devl-swarm-up
devl-swarm-up: ## Start the devl swarm
	vagrant up 176d691
	vagrant up bf37355
	vagrant up ea2d0e1

.PHONY: devl-swarm-down
devl-swarm-down: ## Stop  the devl swarm
	vagrant halt 176d691
	vagrant halt bf37355
	vagrant halt ea2d0e1

.PHONY: test-swarm-up
test-swarm-up: ## Start the test swarm
	printf "\n🚀    Starting docker swarm test environment...\n"
	#  vagrant up 749af64
	#  vagrant up manager-2 
	vagrant up c918ca3

.PHONY: test-swarm-down
test-swarm-down: ## Stop  the test swarm
	vagrant halt 749af64


#==========================================================================================
#  Make make really useful
#==========================================================================================

.PHONY: help
help:
	@uv run python -c "import re; \
	[[print(f'\033[36m{m[0]:<20}\033[0m {m[1]}') for m in re.findall(r'^([a-zA-Z_-]+):.*?## (.*)$$', open(makefile).read(), re.M)] for makefile in ('$(MAKEFILE_LIST)').strip().split()]"
.DEFAULT_GOAL := help

