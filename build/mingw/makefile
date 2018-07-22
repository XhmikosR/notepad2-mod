## MinGW makefile. Designed with <3 by dejbug.

# -- User settings (makefile)

WARNINGS_LEVEL ?= 1
ESCALATE_WARNINGS ?= false
SILENCE_KNOWN_WARNINGS ?= true

# -- User settings (project)

INLINE_ALL ?= false
INLINE_KEYWORD_OVERRIDE ?= 0

NAME ?= Notepad2
ROOT ?= ../..

# -- File paths (project)

RPATH_MAKEFILE := ./build/mingw/makefile
RPATH_VERSION_PY := ./version.py

PATH_MAKEFILE := makefile
PATH_MINGW_BUILD_MACROS_H := mingw_build_macros.h
PATH_ANSIFY_RC := ansify_rc.py
PATH_VERSION_PY := $(ROOT)/version.py
PATH_MANIFEST := $(ROOT)/res/$(NAME).exe.manifest
PATH_REVISION := $(ROOT)/src/VersionRev.h
PATH_RC_ORIGINAL := $(ROOT)/src/Notepad2.rc
PATH_RC_ANSIFIED := $(ROOT)/src/$(NAME).ansi.rc

# -- User settings (extras)
#    (will be amended below with non-negotiable settings)

INCLUDE_DIRS :=
SYMBOLS := BOOKMARK_EDITION UNICODE _UNICODE NDEBUG
WINLIBS :=

COMPILER_FLAGS_COMMON := -msse2 -mthreads -Os
CFLAGS := -std=c99
CXXFLAGS := -std=c++11
LDFLAGS :=

# -- User settings (tools)

CC := gcc
CXX := $(CC)
LD := g++
RC := windres
PYTHON := python


# -- Amendations

INCLUDE_DIRS += $(ROOT)/src
INCLUDE_DIRS += $(ROOT)/scintilla/include
INCLUDE_DIRS += $(ROOT)/scintilla/lexlib
INCLUDE_DIRS += $(ROOT)/scintilla/src


SYMBOLS += MINGW_BUILD
SYMBOLS += WIN32  _WINDOWS  STRICT
SYMBOLS += STATIC_BUILD  SCI_LEXER  USE_D2D
SYMBOLS += _CRT_SECURE_NO_WARNINGS
SYMBOLS += _CRT_SECURE_NO_DEPRECATE
SYMBOLS += _SCL_SECURE_NO_WARNINGS

ifeq ($(INLINE_KEYWORD_OVERRIDE),0)
# Nothing.
else ifeq ($(WARNINGS_LEVEL),1)
SYMBOLS += __inline=inline
else ifeq ($(WARNINGS_LEVEL),2)
SYMBOLS += __inline=__inline__
else ifeq ($(WARNINGS_LEVEL),3)
SYMBOLS += __inline=
endif

WINLIBS += gdi32 comctl32 comdlg32 shlwapi
WINLIBS += uuid ole32 oleaut32
WINLIBS += imm32 msimg32


COMPILER_FLAGS_COMMON += -imacros $(PATH_MINGW_BUILD_MACROS_H)
COMPILER_FLAGS_COMMON += -Wl,--subsystem=windows

ifeq ($(INLINE_ALL),true)
COMPILER_FLAGS_COMMON += -finline-functions
endif

ifeq ($(ESCALATE_WARNINGS),true)
COMPILER_FLAGS_COMMON += -Werror
endif

ifeq ($(WARNINGS_LEVEL),0)
COMPILER_FLAGS_COMMON +=
else ifeq ($(WARNINGS_LEVEL),1)
COMPILER_FLAGS_COMMON += -Wall -Wextra
else ifeq ($(WARNINGS_LEVEL),2)
COMPILER_FLAGS_COMMON += -Wall -Wextra -Winline
else ifeq ($(WARNINGS_LEVEL),3)
COMPILER_FLAGS_COMMON += -Wall -Wextra -Winline -pedantic
endif

ifeq ($(SILENCE_KNOWN_WARNINGS),true)
COMPILER_FLAGS_COMMON += -Wno-unused-parameter
COMPILER_FLAGS_COMMON += -Wno-unused-variable
COMPILER_FLAGS_COMMON += -Wno-unused-but-set-variable
COMPILER_FLAGS_COMMON += -Wno-unused-value
COMPILER_FLAGS_COMMON += -Wno-missing-braces
COMPILER_FLAGS_COMMON += -Wno-missing-field-initializers
COMPILER_FLAGS_COMMON += -Wno-parentheses
COMPILER_FLAGS_COMMON += -Wno-implicit-fallthrough
COMPILER_FLAGS_COMMON += -Wno-sign-compare

CFLAGS += -Wno-incompatible-pointer-types
endif

COMPILER_FLAGS_COMMON += $(addprefix -D,$(SYMBOLS))
COMPILER_FLAGS_COMMON += $(addprefix -I,$(INCLUDE_DIRS))


CFLAGS += $(COMPILER_FLAGS_COMMON)
CXXFLAGS += $(COMPILER_FLAGS_COMMON)
LDFLAGS += $(addprefix -l,$(WINLIBS))


# -- Functions (common)

compile_cxx = $(CXX) -c -o $1 $(filter %.cpp %.cxx %.c,$2) $(CXXFLAGS)
compile_cc = $(CC) -c -o $1 $(filter %.cpp %.cxx %.c,$2) $(CFLAGS)

link_cxx = $(LD) -o $1 $(filter %.o %.a %.dll,$2) $(CXXFLAGS) $(LDFLAGS)
link_cc = $(LD) -o $1 $(filter %.o %.a %.dll,$2) $(CFLAGS) $(LDFLAGS)

create_dir = IF NOT EXIST $(subst /,\,$1) MKDIR $(subst /,\,$1)
move_file = IF EXIST $(subst /,\,$1) MOVE /Y $(subst /,\,$1) $(subst /,\,$2)

make_from_root = $(MAKE) -C $(ROOT) -f $(RPATH_MAKEFILE) $1

ansify_rc = $(PYTHON) $(PATH_ANSIFY_RC) -o $1 -f $(filter %.rc,$2)


# -- Targets (generic)

%.exe : ; $(call link_cc,$@,$^)
%.o : ; $(call compile_cc,$@,$^)
%.rc.o : ; $(RC) -o $@ -i $(filter %.rc,$^)


# -- Targets (main)

.PHONY : all
all : $(PATH_MANIFEST)
all : $(PATH_REVISION)
all : $(NAME).exe

$(PATH_MANIFEST) : $(PATH_REVISION) ;
$(PATH_REVISION) : ; $(call make_from_root,versions)


# -- Targets (main)
#    (to be called into from $(ROOT) )

.PHONY : versions
versions : ; $(PYTHON) $(RPATH_VERSION_PY)


# -- Functions (Scintilla)

SCI_MODS :=
SCI_OBJECTS :=

define sci_mod_target
SCI_$1_DIRPATH := $(ROOT)/scintilla/$1
SCI_$1_SOURCES := $$(wildcard $$(SCI_$1_DIRPATH)/*.$2)
SCI_$1_NAMEXTS := $$(notdir $$(SCI_$1_SOURCES))
SCI_$1_OBJECTS := $$(addprefix $1/,$$(SCI_$1_NAMEXTS:%.$2=%.o))

SCI_MODS += sci_$1
SCI_OBJECTS += $$(SCI_$1_OBJECTS)

sci_mods : sci_$1

.PHONY : sci_$1  sci_$1_folder
sci_$1 : $$(SCI_$1_OBJECTS) ;
sci_$1_folder : ; $$(call create_dir,$1)

$$(SCI_$1_OBJECTS) : $1/%.o : $$(SCI_$1_DIRPATH)/%.$2 | sci_$1_folder
	$$(call compile_cxx,$$@,$$^)
endef


# -- Targets (Scintilla)

.PHONY : sci_mods
sci_mods :
$(eval $(call sci_mod_target,lexers,cxx))
$(eval $(call sci_mod_target,lexlib,cxx))
$(eval $(call sci_mod_target,src,cxx))
$(eval $(call sci_mod_target,win32,cxx))
sci_mods : ; @echo $^


# -- Targets (Notepad2)

NOTEPAD_SOURCES := $(wildcard $(ROOT)/src/*.c)
NOTEPAD_OBJECTS := $(notdir $(NOTEPAD_SOURCES:%.c=%.o))

$(NAME).exe : $(NAME).rc.o  EditPrint_dummy.o
$(NAME).exe : $(NOTEPAD_OBJECTS)  $(SCI_OBJECTS)
$(NAME).rc.o : $(PATH_RC_ANSIFIED)
EditPrint_dummy.o : EditPrint_dummy.c ; $(call compile_cc,$@,$^)
$(PATH_RC_ANSIFIED) : ; $(call ansify_rc,$@,$(PATH_RC_ORIGINAL))
$(NOTEPAD_OBJECTS) : %.o : $(ROOT)/src/%.c ; $(call compile_cc,$@,$^)


# -- Functions (cleanup and run)

delete_file = DEL $(subst /,\,$1) 2>NUL
define delete_files
	$(foreach file,$1,$(call delete_file,$(file))
)
endef
delete_dir = @IF EXIST $(subst /,\,$1) RMDIR /S /Q $(subst /,\,$1)
define delete_dirs
	$(foreach dir,$1,$(call delete_dir,$(dir))
)
endef


# -- Targets (cleanup and run)

.PHONY : clean reset run

clean :
	$(call delete_file,$(NAME).exe)
	$(call delete_files,*.o *.a)
	$(call delete_file,$(PATH_MANIFEST))
	$(call delete_file,$(PATH_REVISION))
	$(call delete_dirs,lexers lexlib src win32)

reset : | clean ;

run : $(NAME).exe ; @.\$<
