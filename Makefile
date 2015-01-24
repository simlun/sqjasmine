SQ := .SQUIRREL3/bin/sq

.PHONY: debug
debug:
	@echo Squirrel interpreter: $(SQ)

$(SQ):
	wget -O .squirrel.tar.gz https://downloads.sourceforge.net/project/squirrel/squirrel3/squirrel%203.0.7%20stable/squirrel_3_0_7_stable.tar.gz
	bash -c "shasum --check <(echo '5ae3f669677ac5f5d663ec070d42ee68980e1911  .squirrel.tar.gz')"
	tar zxf .squirrel.tar.gz
	mv SQUIRREL3 .SQUIRREL3
	(cd .SQUIRREL3; make)

.PHONY: test
test: $(SQ)
	$(SQ) helper-specs.nut
	$(SQ) documentation-specs.nut

.PHONY: clean
clean:
	rm -rf .SQUIRREL3 .squirrel.tar.gz
