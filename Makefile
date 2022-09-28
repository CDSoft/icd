
BUILD	:= build
SRC		:= icd.lua $(wildcard lib/*.lua) $(wildcard lib/backend/*.lua)
TESTS	:= $(sort $(wildcard tests/*.lua))
TESTLIB := $(wildcard tests/lib/*.lua)
OK		:= $(patsubst tests/%.lua,$(BUILD)/%.h.ok,$(TESTS))
OK		+= $(patsubst tests/%.lua,$(BUILD)/%.c.ok,$(TESTS))
OK		+= $(patsubst tests/%.lua,$(BUILD)/%.sh.ok,$(TESTS))
OK		+= $(patsubst tests/%.lua,$(BUILD)/%.rst.ok,$(TESTS))
OK		+= $(patsubst tests/%.lua,$(BUILD)/%.hs.ok,$(TESTS))
OK		+= $(patsubst tests/%.lua,$(BUILD)/%.asy.ok,$(TESTS))
OK		+= $(patsubst tests/%.lua,$(BUILD)/%.yaml.ok,$(TESTS))
DIFF_OK	:= $(patsubst $(BUILD)/%.ok,$(BUILD)/%.nodiff,$(OK))

CLANGTIDY	:= clang-tidy
CLANGTIDY	+= -checks=*,-llvm-header-guard
CLANGTIDY	+= -warnings-as-errors=*
CLANGTIDY	+= -quiet

SHELLCHECK	+= shellcheck

.SECONDARY:

all: test

clean:
	rm -rf ${BUILD}

test: $(OK) $(DIFF_OK)
	# All tests passed

$(BUILD)/%.c $(BUILD)/%.h $(BUILD)/%.sh $(BUILD)/%.rst $(BUILD)/%.hs $(BUILD)/%.asy $(BUILD)/%.yaml: tests/%.lua $(SRC) $(TESTLIB)
	@mkdir -p $(dir $@)
	./icd.lua $< -o $@ -M $@.d -c -sh -rst -hs -asy -yaml --cpp-const

$(BUILD)/%.c.ok $(BUILD)/%.h.ok: $(BUILD)/%.c $(BUILD)/%.h
	$(CLANGTIDY) $<
	gcc -fsyntax-only $<
	clang -fsyntax-only $<
	@touch $@

$(BUILD)/%.sh.ok: $(BUILD)/%.sh
	$(SHELLCHECK) $<
	bash -c ". $<"
	zsh -c ". $<"
	@touch $@

$(BUILD)/%.rst.ok: $(BUILD)/%.rst
	test "`pandoc $< -t native`" = "[]"
	@touch $@

$(BUILD)/%.hs.ok: $(BUILD)/%.hs
	@mkdir -p $(BUILD)/haskell
	stack ghc -- -Wall -Werror -tmpdir $(BUILD)/haskell -dumpdir $(BUILD)/haskell -hidir $(BUILD)/haskell -odir $(BUILD)/haskell -outputdir $(BUILD)/haskell $<
	@touch $@

$(BUILD)/%.asy.ok: $(BUILD)/%.asy
	asy $<
	@touch $@

$(BUILD)/%.yaml.ok: $(BUILD)/%.yaml
	python -c 'import yaml, sys; print(yaml.safe_load(sys.stdin))' < $<
	yamllint $<
	@touch $@

$(BUILD)/%.nodiff: $(BUILD)/% tests/%
	diff $^ #|| meld $^
	@touch $@

tests/%.h tests/%.c tests/%.sh tests/%.rst tests/%.hs tests/%.asy tests/%.yaml:
	test -e $@ || ( echo "Please write the test result here." > $@ )

-include $(wildcard $(BUILD)/*.d)
