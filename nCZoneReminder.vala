using Gtk;
using Notify;

extern void exit(int exit_code);

namespace nCZone {

    class Reminder : GLib.Object {
        
        public static int main(string[] args) {
            Gtk.init(ref args);
            var loop = new MainLoop();

            var config = new ReminderConfig();
            var api = new ReminderAPI(config);
            var notify = new ReminderNotify();
            config.read();
            var ui = new ReminderUI(config);
            ui.on_quit.connect(() => {
                config.write();
                exit(0);
            });
            var manager = new ReminderManager(config, api, notify);
            manager.loop.begin((obj, res) => {
                manager.loop.end(res);
            });
            loop.run();

            Gtk.main();

            return 0;
        }
    }

}