#include <X11/Xlib.h>

XIC prompt_create_ic(Display *display, Window window) {
  XIM im; XIC ic;
  if (XSetLocaleModifiers("@im=none") == NULL) return NULL;
  im = XOpenIM(display, NULL, NULL, NULL);
  XSetLocaleModifiers(""); // Restore environment defaults
  if (im == NULL) return NULL;
  ic = XCreateIC(im, XNInputStyle, XIMPreeditNothing | XIMStatusNothing, XNClientWindow, window, XNFocusWindow, window, NULL);
  if (ic == NULL) XCloseIM(im); else XSetICFocus(ic);
  return ic;
}

void prompt_destroy_ic(XIC ic) { XIM im = XIMOfIC(ic); XUnsetICFocus(ic); XDestroyIC(ic); XCloseIM(im); }

int prompt_lookup_str(XIC ic, XKeyEvent *event, unsigned char *buffer, int size) {
  Status status; int count = Xutf8LookupString(ic, event, (char *) buffer, size, NULL, &status);
  if (status == XBufferOverflow) return -count;
  return status == XLookupChars || status == XLookupBoth ? count : 0;
}
