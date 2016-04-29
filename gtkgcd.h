//
// A small utility for listening for GTK events on a dispatch queue.
//

#import <gtk/gtk.h>

int gtkgcd_get_X11_fd(GtkWidget *gwidget);
void gtkgcd_watch_fd(int fd);
void gtkgcd_sync();
void gtkgcd_launch(GtkWidget *widget);
