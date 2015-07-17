telegram-bot-rbash
===
This is a `bash` executor on Telegram Bot platform, based on `telegram-bot-coffee`

NOTICE
===
This executor runs commands with `rbash`, a.k.a `restricted bash`. With this, unsafe commands cannot be executed.

However, you should set up a seperate `$PATH` for the restrcited shell, and put only safe commands there. Commands that can execute other commands should not be linked there.

Then add two options in the config file of `telegram-bot-coffee`

`rbash`: the path to the `rbash` executable
`rbashpath`: the seperate `$PATH` you set for the `rbash` shell

The max execution time is limited to 500ms.

PLEASE RUN THE BOT WITH `nobody` or other users without dangerous permissions!
