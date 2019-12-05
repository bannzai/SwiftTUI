#include "include/ncurses.h"
#include <wchar.h>

typedef struct
{
  int         attr;
  wchar_t     chars[5];
} m_cchar_t;

