using GSound;

namespace nCZone {

    class ReminderNotify : GLib.Object {

        private const string login = "login.ogg";
        private const string logout = "logout.ogg";
        private const string match = "match.ogg";
        private const string error = "error.ogg";

        protected GSound.Context sound_ctx;

        public ReminderNotify() {
            try {
                sound_ctx = new GSound.Context();
            } catch(GLib.Error e) {
                stderr.printf("Error initializing GSound context: \"%s\"\n", e.message);
            }
            Notify.init("nC Zone Reminder");
        }

        public void login_sound() {
            this.sound(ReminderNotify.login);
        }

        public void logout_sound() {
            this.sound(ReminderNotify.logout);
        }

        public void match_sound() {
            this.sound(ReminderNotify.match);
        }

        public void error_sound() {
            this.sound(ReminderNotify.error);
        }

        public void login_message() {
            this.message("Jemand hat sich eingeloggt!");
        }

        public void logout_message() {
            this.message("Jemand hat sich ausgeloggt!");
        }

        public void match_message() {
            this.message("Du wurdest gelost!");
        }

        public void error_message() {
            this.message("Ein Fehler ist aufgetreten!");
        }

        protected void sound(string filename) {
            try {
                sound_ctx.play_simple(null, GSound.Attribute.MEDIA_FILENAME, filename);
            } catch(GLib.Error e) {
                this.error_message();
                stderr.printf("Error playing sound: \"%s\"\n", e.message);
            }
        }

        protected void message(string message) {
            try {
                new Notify.Notification("nC Zone Reminder", message, "dialog-information").show();
            } catch(GLib.Error e) {
                this.error_sound();
                stderr.printf("Error sending notification: \"%s\"\n", e.message);
            }
        }

    }
}