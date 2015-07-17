telegram-bot-rbash
===

This is a `bash` executor module for `telegram-bot-coffee`.

NOTICE
------

This executor runs commands with `rbash`, a.k.a `restricted bash`. With this,
commands out of `$PATH` cannot be executed. However, you should set up a seperate
`$PATH` for the restrcited shell, and put only safe commands there. Commands
that can execute other commands should not be linked there.


The max execution time is limited to 500ms.

PLEASE RUN THE BOT WITH `nobody` or other users without dangerous permissions!

References
----------

* GNU bash manual 6.10, [Restricted Shell](http://www.gnu.org/software/bash/manual/html_node/The-Restricted-Shell.html).
