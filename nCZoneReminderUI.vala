using Gtk;

namespace nCZone {

    class ReminderUI : GLib.Object {

        protected ReminderConfig config;

        protected Window window;
        protected Entry username;
        protected Entry api;
        protected Adjustment interval;
        protected ToggleButton loginout;
        protected ToggleButton draw;
        protected ToggleButton sound;
        protected ToggleButton notification;
        protected ToggleButton pause;

        public ReminderUI(ReminderConfig config) {
            this.config = config;

            var builder = new Builder();
            try {
                builder.add_from_file("reminder.ui");
            } catch(Error e) {
                stderr.printf("Error loading UI: \"%s\"\n", e.message);
            }
            builder.connect_signals(this);

            this.window = builder.get_object("main_window") as Window;
            this.username = builder.get_object("username_entry") as Entry;
            this.api = builder.get_object("api_entry") as Entry;
            this.interval = builder.get_object("interval") as Adjustment;
            this.loginout = builder.get_object("loginout_toggle") as ToggleButton;
            this.draw = builder.get_object("draw_toggle") as ToggleButton;
            this.sound = builder.get_object("sound_toggle") as ToggleButton;
            this.notification = builder.get_object("notification_toggle") as ToggleButton;
            this.window.destroy.connect(this.quit);

            this.window.show_all();

            this.apply_config();
        }

        protected void apply_config() {
            Config temp_config = this.config.config;

            this.username.text = temp_config.username;
            this.api.text = temp_config.api;
            this.interval.value = temp_config.interval;
            this.loginout.set_active(temp_config.loginout);
            this.draw.set_active(temp_config.draw);
            this.sound.set_active(temp_config.sound);
            this.notification.set_active(temp_config.notification);
            this.pause.set_active(temp_config.pause);
        }

        public void update_infos() {
            Config new_config = Config(this.username.text, this.api.text, (int)this.interval.value,
                                       this.loginout.get_active(), this.draw.get_active(),
                                       this.sound.get_active(), this.notification.get_active(),
                                       this.pause.get_active());
            this.config.config = new_config;
        }

        [CCode(instance_pos=-1)]
        public void on_change(Widget source) {
            this.update_infos();
        }

        [CCode(instance_pos=-1)]
        public void quit(Widget source) {
            this.on_quit();
        }

        public signal void on_quit();
    }
}