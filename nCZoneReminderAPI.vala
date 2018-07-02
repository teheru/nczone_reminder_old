using Json;
using Soup;

namespace nCZone {

    class ReminderAPI : GLib.Object {

        protected ReminderConfig config;
        protected string api_logged_in;
        protected string api_matches;

        protected int[] logged_in_ids;
        protected bool in_match;

        public ReminderAPI(ReminderConfig config) {
            this.config = config;
            this.config.on_update.connect(this.config_change);

            this.set_api(config.config.api);

            this.in_match = false;
        }

        public void set_api(string api) {
            this.api_logged_in = api + "/players/logged_in";
            this.api_matches = api + "/matches/running";
        }

        public void query_logged_in() {
            string resp = "";
            var session = new Soup.Session();
            var message = new Soup.Message("GET", api_logged_in);
            session.send_message(message);
            resp = (string)message.response_body.flatten().data;
            
            var parser = new Json.Parser();
            try {
                parser.load_from_data(resp);
            } catch(Error e) {
                stderr.printf("Error getting logged in list: \"%s\"\n", e.message);
                this.on_error();
            }
            var players = parser.get_root().get_array().get_elements();

            bool add_id = false;
            bool rem_id = false;

            int[] temp_ids = {};
            foreach(var player_node in players) {
                int user_id = (int)player_node.get_object().get_int_member("id");
                temp_ids += user_id;
                if(!(user_id in logged_in_ids)) {
                    add_id = true;
                }
            }
            foreach(int user_id in logged_in_ids) {
                if(!(user_id in temp_ids)) {
                    rem_id = true;
                    break;
                }
            }

            this.logged_in_ids = temp_ids;

            if(add_id) {
                on_login();
            }
            if(rem_id) {
                on_logout();
            }
        }

        public void query_draw() {
            string resp = "";
            var session = new Soup.Session();
            var message = new Soup.Message("GET", api_matches);
            session.send_message(message);
            resp = (string)message.response_body.flatten().data;

            bool temp_in_match = false;
            
            string my_username = this.config.config.username.down();

            var parser = new Json.Parser();
            try {
                parser.load_from_data(resp);
            } catch(Error e) {
                stderr.printf("Error getting matches list: \"%s\"\n", e.message);
                this.on_error();
            }
            var matches = parser.get_root().get_array().get_elements();
            foreach(var match in matches) {
                var players = match.get_object().get_object_member("players");
                foreach(var player in players.get_array_member("team1").get_elements()) {
                    string test_username = player.get_object().get_string_member("username").down();
                    if(my_username == test_username) {
                        temp_in_match = true;
                        break;
                    }
                }
                if(!temp_in_match) {
                    foreach(var player in players.get_array_member("team2").get_elements()) {
                        string test_username = player.get_object().get_string_member("username").down();
                        if(my_username == test_username) {
                            temp_in_match = true;
                            break;
                        }
                    }
                }
                if(temp_in_match) {
                    break;
                }
            }

            if(!this.in_match && temp_in_match) {
                this.on_match();
            }
            this.in_match = temp_in_match;
        }

        protected void config_change() {
            this.set_api(this.config.config.api);
        }

        public signal void on_login();
        public signal void on_logout();
        public signal void on_match();
        public signal void on_error();
    }
}