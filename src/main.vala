using Config;
using Config2;
using Gtk;
using Posix;

public class Iccloader : Object {
    private Gtk.Window window;
    private Gtk.StatusIcon tray_icon;
    private Gtk.Menu menu;

    public Iccloader () {
        // UI
        var builder = new Gtk.Builder ();
        try {
            builder.add_from_file (Path.build_filename (Config2.DATA_DIR, "main.ui"));
        } catch (Error e) {
            GLib.stderr.printf ("UI loading error: %s\n", e.message);
            Posix.exit (1);
        }
        window = builder.get_object ("window1") as Window;
        var label = builder.get_object ("label1") as Label;
        window.title = Config.PACKAGE_NAME;
        label.label = "Hello, world!";
        window.destroy.connect (Gtk.main_quit);

        // window icon
        try {
            window.icon = Gtk.IconTheme.get_default ().load_icon (Config.PACKAGE, 48, 0);
        } catch (Error e) {
            // GLib.stderr.printf ("Could not load the window icon from the default theme: %s\n", e.message);
            try {
                window.icon = new Gdk.Pixbuf.from_file (Path.build_filename (Config2.ICON_DIR, @"$(Config.PACKAGE).svg"));
            } catch (Error e) {
                GLib.stderr.printf ("Could not load the window icon from the SVG file: %s\n", e.message);
            }
        }

        window.show_all ();
    }

    public void setup_system_tray () {
        tray_icon = new Gtk.StatusIcon.from_pixbuf (window.icon);
        tray_icon.tooltip_text = Config.PACKAGE_NAME;
        tray_icon.visible = true;
        menu = new Gtk.Menu();
        var menu_foo = new Gtk.ImageMenuItem.with_mnemonic ("_Foo");
        menu.append (menu_foo);
        var menu_pref = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.PREFERENCES, null);
        menu.append (menu_pref);
        var menu_sep = new Gtk.SeparatorMenuItem ();
        menu.append (menu_sep);
        var menu_quit = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.QUIT, null);
        menu_quit.activate.connect (Gtk.main_quit);
        menu.append (menu_quit);
        menu.show_all ();
        tray_icon.popup_menu.connect (menu_popup);
    }
    
    private void menu_popup (uint button, uint time) {
        menu.popup (null, null, null, button, time);
    }
}

int main (string[] args) {
    Gtk.init (ref args);
    var iccloader = new Iccloader ();
    iccloader.setup_system_tray ();

    Gtk.main ();
    return 0;
}

