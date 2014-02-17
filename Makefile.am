EMPTY =
SUBDIRS = po
bin_PROGRAMS = iccloader
iccloader_SOURCES =\
		   src/solpos/solpos.c\
		   src/config2.vala\
		   src/main.vala\
		   $(EMPTY)

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
ui_DATA = data/preferences.ui\
	  $(EMPTY)

desktopdir = $(datadir)/applications
desktop_in_files = data/@PACKAGE@.desktop.in
desktop_DATA = data/@PACKAGE@.desktop
@INTLTOOL_DESKTOP_RULE@

MOSTLYCLEANFILES = src/config2.vala\
				   $(desktop_DATA)

EXTRA_DIST = autogen.sh\
	     src/config2.vala.in\
	     $(ui_DATA)\
		 $(desktop_in_files).in\
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
		-e 's#@LOCALE_DIR@#$(datadir)/locale#g' \
		$< > $(top_srcdir)/$@

clean-local:
	-rm -f src/*.c

dist-hook:
	rm -f $(distdir)/src/config2.vala
	rm -f $(distdir)/src/*.c

