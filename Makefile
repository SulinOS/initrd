install:
	[ -d $(DESTDIR)/lib/initrd/ ] && rm -rf $(DESTDIR)/lib/initrd/ || true
	mkdir $(DESTDIR)/lib/initrd/
	mkdir $(DESTDIR)/lib/initrd/locale
	cp -prfv src/* $(DESTDIR)/lib/initrd/
	cp -prfv locale/* $(DESTDIR)/lib/initrd/locale
	[ -f $(DESTDIR)/bin/update-initrd ] && rm -f $(DESTDIR)/bin/update-initrd || true
	ln -s $(DESTDIR)/lib/initrd/build.sh $(DESTDIR)/bin/update-initrd
	chmod +x $(DESTDIR)/lib/initrd/build.sh
