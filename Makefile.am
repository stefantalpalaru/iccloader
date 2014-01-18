EMPTY =
bin_PROGRAMS = iccloader
iccloader_SOURCES =\
		   src/solpos/solpos.c\
		   src/config2.vala\
		   src/main.vala\
		   $(EMPTY)

MOSTLYCLEANFILES = src/config2.vala

iccloader_VALAFLAGS = --target-glib @GLIB_VERSION@ --vapidir=$(top_srcdir)/vapi --vapidir=$(top_srcdir)/src/solpos --pkg=config --pkg=gtk+-3.0 --pkg=posix --pkg=gio-2.0 --pkg=solpos

LIBS =\
      @gtk_LIBS@\
	  -lm\
	  $(EMPTY)

AM_CFLAGS =\
	   @gtk_CFLAGS@\
	   -I $(top_srcdir)/src/solpos\
	   $(EMPTY)

iconthemedir = $(datadir)/icons/hicolor
appiconscalabledir = $(iconthemedir)/scalable/apps
dist_appiconscalable_DATA = data/iccloader.svg

uidir = $(pkgdatadir)/
ui_DATA = data/*.ui\
	  $(EMPTY)

EXTRA_DIST = autogen.sh\
	     src/config2.vala.in\
	     $(ui_DATA)\
	     vapi\
	     .gitignore\
	     *.ebuild\
		 src/solpos/*.c\
		 src/solpos/*.h\
		 src/solpos/*.vala\
		 src/solpos/*.vapi\
		 src/solpos/*.sh\
		 screenshots\
	     $(EMPTY)

src/config2.vala: src/config2.vala.in
	sed -e 's#@ICON_DIR@#$(appiconscalabledir)#g' \
		-e 's#@DATA_DIR@#$(pkgdatadir)#g' \
		$< > $(top_srcdir)/$@

clean-local:
	-rm -f src/*.c

dist-hook:
	rm -f $(distdir)/src/config2.vala
	rm -f $(distdir)/src/*.c

