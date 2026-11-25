#include "SDL_internal.h"
#include "../../sdl/src/core/linux/SDL_dbus.h"

#ifdef SDL_USE_LIBDBUS
#include "../../sdl/src/core/linux/SDL_system_theme.c"
#else
#include "../../sdl/src/core/linux/SDL_system_theme.h"

bool SDL_SystemTheme_Init(void)
{
    return false;
}

SDL_SystemTheme SDL_SystemTheme_Get(void)
{
    return SDL_SYSTEM_THEME_UNKNOWN;
}
#endif
