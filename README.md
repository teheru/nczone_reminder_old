# nC Zone Reminder

The nC Zone Reminder is a tool to locally observe a nC Zone (https://github.com/teheru/nczone) and tell if something
happens.

## Compile
`valac --pkg libsoup-2.4 --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg json-glib-1.0 --pkg gio-2.0 --pkg gsound --pkg libnotify nCZoneReminder.vala nCZoneReminderUI.vala nCZoneReminderConfig.vala nCZoneReminderAPI.vala nCZoneReminderNotify.vala nCZoneReminderManager.vala`

## Run
You need the following sound files in order to run use the Reminder: `login.ogg`, `logout.ogg`, `match.ogg`, `error.ogg`

## License
[GPLv2](LICENSE)