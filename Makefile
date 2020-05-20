install:
	[ -d $(DESTDIR)/lib/initrd/ ] && rm -rf $(DESTDIR)/lib/initrd/ || true
	mkdir -p $(DESTDIR)/lib/initrd/
	mkdir -p $(DESTDIR)/lib/initrd/locale
	mkdir -p $(DESTDIR)/lib/initrd/locale/helpmsg
	cp -prfv src/* $(DESTDIR)/lib/initrd/
	cp -prfv locale/* $(DESTDIR)/lib/initrd/locale
	cp -prfv locale/helpmsg/* $(DESTDIR)/lib/initrd/locale/helpmsg
	[ -f $(DESTDIR)/bin/update-initrd ] && rm -f $(DESTDIR)/bin/update-initrd || true
	ln -s $(DESTDIR)/lib/initrd/build.sh $(DESTDIR)/bin/update-initrd
	chmod +x $(DESTDIR)/lib/initrd/build.sh
