//
// GTKGCD Integration
//

#include <gtk/gtk.h>
#include <gdk/gdkx.h>  // to get gdk_x11_display_get_xdisplay
#include <dispatch/dispatch.h>

static GMainContext *gtkgcd_context = NULL;

//
// determine the file descriptor for the X display given a widget (main window)
//

int gtkgcd_get_X11_fd(GtkWidget *gwidget) {

  GdkDisplay *gdisp = gtk_widget_get_display(gwidget);
  if (gdisp == NULL) {
    fprintf(stderr, "GTKGCD: cannot find GdkGdisplay\n");
    return -1;
  }
  
  Display *xdisp = gdk_x11_display_get_xdisplay(gdisp);
  if (xdisp == NULL) {
    fprintf(stderr, "GTKGCD: cannot find xdisplay\n");
    return -1;
  }

  int fd = ConnectionNumber(xdisp);
  fprintf(stderr, "X11 fd:%d\n", fd);
  return fd;
}

//
// add the file descriptor to the dispatch sources
//


void gtkgcd_watch_fd(int fd) {

  // and create a dispatch source for it
  dispatch_source_t dsource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
						     fd,
						     0,
						     dispatch_get_main_queue());
  dispatch_source_set_event_handler(dsource, ^{

      while (g_main_context_pending(gtkgcd_context)) {
	g_main_context_iteration(gtkgcd_context, FALSE);
      }

    });

  // enable the dispatch source
  dispatch_resume(dsource);
  
}

//
// flush pending events
//

void gtkgcd_sync() {

  dispatch_async(dispatch_get_main_queue(), ^{

      while (g_main_context_pending(gtkgcd_context)) {
	g_main_context_iteration(gtkgcd_context, FALSE);
      }

    });
}

//
// Given a widget in the application, find its X11 file descriptor
// and launch a dispatch source handler for it.
//

void gtkgcd_launch(GtkWidget *widget) {

  gtkgcd_context = g_main_context_default();

  // initial launch of graphics
  while (g_main_context_pending(gtkgcd_context)) {
    g_main_context_iteration(gtkgcd_context, FALSE);
  }

  int fd = gtkgcd_get_X11_fd(widget);
  gtkgcd_watch_fd(fd);
}

