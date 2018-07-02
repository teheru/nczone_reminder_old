namespace nCZone {

    class ReminderManager : GLib.Object {

        protected ReminderConfig config;
        protected ReminderAPI api;
        protected ReminderNotify notification;

        public ReminderManager(ReminderConfig config, ReminderAPI api, ReminderNotify notification) {
            this.config = config;
            this.api = api;
            this.notification = notification;

            this.api.on_login.connect(this.login);
            this.api.on_logout.connect(this.logout);
            this.api.on_match.connect(this.match);
            this.api.on_error.connect(this.error);
        }

        public async void loop() {
            ThreadFunc<bool> run = () => {
                while(true) {
                    if(!this.config.config.pause) {
                        if(this.config.config.loginout) {
                            this.api.query_logged_in();
                        }
                        if(this.config.config.draw) {
                            this.api.query_draw();
                        }
                    }
                    GLib.Thread.usleep(this.config.config.interval * (ulong)1e6);
                }
                return true;
            };
            new Thread<bool>("", run);
        }

        public void login() {
            if(this.config.config.sound) {
                this.notification.login_sound();
            }
            if(this.config.config.notification) {
                this.notification.login_message();
            }
        }

        public void logout() {
            if(this.config.config.sound) {
                this.notification.logout_sound();
            }
            if(this.config.config.notification) {
                this.notification.logout_message();
            }
        }

        public void match() {
            if(this.config.config.sound) {
                this.notification.match_sound();
            }
            if(this.config.config.notification) {
                this.notification.match_message();
            }
        }

        public void error() {
            this.notification.error_sound();
            this.notification.error_message();
        }
    }
}