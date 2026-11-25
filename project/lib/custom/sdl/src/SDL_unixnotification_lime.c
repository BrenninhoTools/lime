#include "SDL_internal.h"
#include "../../sdl/src/core/linux/SDL_dbus.h"

#ifdef SDL_USE_LIBDBUS
#include "../../sdl/src/notification/unix/SDL_dbusnotification.c"
#else
#include "../../sdl/src/notification/dummy/SDL_dummynotification.c"
#endif
