install:
	[ -d $(DESTDIR)/lib/initrd/ ] && rm -rf $(DESTDIR)/lib/initrd/ || true
	mkdir $(DESTDIR)/lib/initrd/
	cp -prfv src/* $(DESTDIR)/lib/initrd/
	[ -f $(DESTDIR)/bin/update-initrd ] && rm -f $(DESTDIR)/bin/update-initrd || true
	ln -s $(DESTDIR)/lib/initrd/build.sh $(DESTDIR)/bin/update-initrd
	chmod +x $(DESTDIR)/lib/initrd/build.sh
