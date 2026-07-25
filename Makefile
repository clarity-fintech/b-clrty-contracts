MISC ?= ../../bin/misc
ifeq ($(wildcard $(MISC)),)
  MISC := bin/misc
endif
.PHONY: check commands-check network-connect
check:
	@test -x $(MISC) || (echo "need bin/misc"; exit 1)
	$(MISC) mis/kernel/BClrtyContractsKernel.mis --check --compact-letters
	@find mis -name '*.mis' | while read f; do $(MISC) "$$f" --check --compact-letters || exit 1; done
	@echo OK b-clrty-contracts

.PHONY: commands-check network-connect
commands-check:
	@test -x $(MISC) || (echo "need bin/misc"; exit 1)
	@find mis/commands -name '*.mis' 2>/dev/null | while read f; do $(MISC) "$$f" --check --compact-letters || exit 1; done
	@echo OK commands $(notdir $(CURDIR))

network-connect: commands-check
	@echo CONNECTED clrty-1/1202 $(notdir $(CURDIR))
	@echo RPC https://rpc.clarity-fintech.com
	@echo MODULES mis/commands/BClrtyContractsCommands.mis
