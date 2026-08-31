#
# uvc-util — USB Video Class (UVC) control management utility for macOS
#
# Build for this machine:
#     make
#
# Build a universal (x86_64 + arm64) binary, as the release workflow does:
#     make universal
#
# Install (defaults to /usr/local/bin/uvc-util):
#     make install PREFIX=/usr/local
#

PREFIX          ?= /usr/local
BINDIR          ?= $(PREFIX)/bin
DESTDIR         ?=

CC              ?= cc
INSTALL         ?= install

CFLAGS          ?= -Os
CFLAGS          += -std=gnu99 -Wall
LDLIBS          += -framework IOKit -framework Foundation

SRCDIR          := src
BUILDDIR        := build
TARGET          := uvc-util
SOURCES         := $(SRCDIR)/uvc-util.m $(SRCDIR)/UVCController.m $(SRCDIR)/UVCType.m $(SRCDIR)/UVCValue.m
HEADERS         := $(wildcard $(SRCDIR)/*.h)
OBJECTS         := $(SOURCES:.m=.o)

# Slices built by the `universal` target.  The floor is macOS 12 because
# UVCController uses kIOMainPortDefault, which does not exist before then.
SLICES          := x86_64 arm64
MACOS_MIN       ?= 12.0
SLICE_BINARIES  := $(patsubst %,$(BUILDDIR)/$(TARGET)-%,$(SLICES))

.PHONY: all universal clean install uninstall

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(OBJECTS) $(LDLIBS)

$(OBJECTS): $(HEADERS)

%.o: %.m
	$(CC) $(CFLAGS) -c -o $@ $<

# lipo strips the per-slice ad-hoc signatures, so the merged binary has to be
# re-signed or it will not run on Apple silicon.
universal: $(SLICE_BINARIES)
	lipo -create -output $(TARGET) $(SLICE_BINARIES)
	codesign --force --sign - $(TARGET)

$(BUILDDIR)/$(TARGET)-%: $(SOURCES) $(HEADERS)
	@mkdir -p $(BUILDDIR)
	$(CC) $(CFLAGS) -arch $* -mmacosx-version-min=$(MACOS_MIN) $(LDFLAGS) -o $@ $(SOURCES) $(LDLIBS)

install: $(TARGET)
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -m 0755 $(TARGET) $(DESTDIR)$(BINDIR)/$(TARGET)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(TARGET)

clean:
	rm -rf $(OBJECTS) $(TARGET) $(BUILDDIR)
