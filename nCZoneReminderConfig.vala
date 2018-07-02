using Json;

namespace nCZone {

    struct Config {
        public string username;
        public string api;
        public int interval;
        public bool loginout;
        public bool draw;
        public bool sound;
        public bool notification;
        public bool pause;

        public Config(string username, string api, int interval,
                      bool loginout, bool draw, bool sound, bool notification,
                      bool pause) {
            this.username = username;
            this.api = api;
            this.interval = interval;
            this.loginout = loginout;
            this.draw = draw;
            this.sound = sound;
            this.notification = notification;
            this.pause = pause;
        }

        public Config.empty() {
            this.username = "";
            this.api = "";
            this.interval = 30;
            this.loginout = true;
            this.draw = true;
            this.sound = true;
            this.notification = true;
            this.pause = true;
        }
    }
    
    class ReminderConfig : GLib.Object {

        private string filename = "config";

        protected Config _config;
        public Config config {
            get { return this._config; }
            set {
                this._config = value;
                on_update();
            }
        }

        public ReminderConfig() {
            this.config = Config.empty();
        }

        public void read() {
            if(File.new_for_path(this.filename).query_exists()) {
                var parser = new Json.Parser();
                try {
                    parser.load_from_file(this.filename);
                } catch(Error e) {
                    stderr.printf("Error reading config file: \"%s\"\n", e.message);
                }
                var root_object = parser.get_root().get_object();
                
                this.config = Config((string)root_object.get_string_member("username"),
                                     (string)root_object.get_string_member("api"),
                                     (int)root_object.get_int_member("interval"),
                                     root_object.get_int_member("loginout") == 1,
                                     root_object.get_int_member("draw") == 1,
                                     root_object.get_int_member("sound") == 1,
                                     root_object.get_int_member("notification") == 1,
                                     root_object.get_int_member("pause") == 1);
            }
        }

        public void write() {
            var values = new Json.Object();
            values.set_string_member("username", this.config.username);
            values.set_string_member("api", this.config.api);
            values.set_int_member("interval", this.config.interval);
            values.set_int_member("loginout", this.config.loginout ? 1 : 0);
            values.set_int_member("draw", this.config.draw ? 1 : 0);
            values.set_int_member("sound", this.config.sound ? 1 : 0);
            values.set_int_member("notification", this.config.notification ? 1 : 0);
            values.set_int_member("pause", this.config.pause ? 1 : 0);

            var gen = new Generator();
            var root = new Json.Node(NodeType.OBJECT);
            root.set_object(values);
            gen.set_root(root);

            size_t length;
            string json = gen.to_data(out length);
            
            try {
                FileUtils.set_contents(this.filename, json);
            } catch(Error e) {
                stderr.printf("Error writing config file: \"%s\"\n", e.message);
            }
        }

        public signal void on_update();
    }
}