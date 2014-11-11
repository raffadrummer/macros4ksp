CPP = cpp-4.9

.PHONY: clean

%.txt: %.ksp
	@$(CPP) -P $< | \
		perl -0777 -p -e 's/@@@\s*/\n/msg;' | \
		perl -0777 -p -e 's/({.*?})//msg; s/^\s*\n//msg; s/^\s*//msg;' > $@
	@echo "Compiled '$<' in '$@'"
