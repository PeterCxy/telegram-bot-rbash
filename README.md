telegram-bot-rbash
==================

This is a `bash` executor module for `telegram-bot-coffee`. It can also be
configured to run other interactive programs via stdin, e.g. `python`.

By default it runs commands with `bash -r`, the Restricted Shell. Running
commands out of `PATH` would be impossible since no slashes in commands 
are allowed. Changing directories is also impossible, read the References
for more detail.

The bot also features a max execution time limit, and startup/cleanup code
injection.

Configuration
-------------

This bot's default configuration is shown as the `rbash` object in `config`.

The object contains the following fields:

* `time`: **String** Max execution time, in ms.
* `bash`: **String** The shell to run.
* `args`: **String Array** Arguments to pass to the shell.
* `spawn`: **Object** Options for `child_process`'s `spawn`， read the ref.
  * `cwd`: **String** Current working directory. Personally I suggest a
    read-only empty one or a 32Mib-tmpfs with cron scheduled to delete it.
  * `env`: **Object** Environmental Variables.
    * `PATH`: **String** The `$PATH`.
	* `BASH_ENV`: **String** The path where bash would attempt to read an RC
	  from. It's recommended to set it instead of `startup`, since it won't
	  mess up with line number recording features like `$LINENO`.<br/>
	  Additional improvements from it includes having same safety in forked
	  `rbash` commands if `BASH_ENV` is `readonly`.
* `startup`: **String** The startup string to add to beginning of stdin, a.k.a.
  **hard-coded rc**.
* `cleanup`: **String** The cleanup string to pad to end of stdin.

If you are interested in luking the whole thing, read `rbash.coffee` for
implementation and defaults.

For each key on the top-level, `rbash.coffee` will verify their `typeof`s and
assign the default on mismatch. Uncommenting lines in `rbash.coffee` enables
recursive default-assigning on Objects.

Deployment
----------

For security, you should run the shell in a container or something else with
a low permission. You can consider setting `bash` to `sudo`, and `args` to
`[ '-u', 'nobody', 'bash', '-r' ]` and vice versa. Chroot configuration is
almost the same. User-switching with `spawn.uid` and `spawn.gid` may also be
tried.

Advanced startup configuration with `ulimit` should be enforced, and the user
should not be able to edit it later. A roughly working one is already in the
defaults.

A careful selection of programs in `PATH` should be enforced, or again, use an
empty overlayfs chroot with only `busybox` stuffs (but not its sh) inside and
`/dev/null`, `/dev/console`.

Sensitive variables like `PAGER` and `EDITOR` should be readonly. Also default.
Before adding other programs, please also check if they calls other programs.
If the program calls other programs as specified in the command-line arguments,
consider using a shell function and an executor to verify it, as shown in this
pseudo-code:

```Bash
# Startup-side configuration, for foo that do bad things with -c 'blah' and -R
foo(){
	local OPTIND OPTARG OPTERR OPT ARGV=()
	while getopts 'efgc:R' OPT; do
		if [[ "$OPT" == [cR] ]]; then
			echo "foo: -$OPT not allowed.">&2
		else
			ARGV+=("$OPT")
			[ -z "$OPTARG"] || ARGV+=("$OPTARG")
		fi
	done
	shift $((OPTIND-1))
	
	wrap foo "${ARGV[@]}" "$@"
}
```

```Bash
#!/bin/bash
# wrap: check the allowed list and run if ok. No longer in restrcited.
shopt -s extglob
OLDPATH="$PATH"
export PATH='/usr/bin' # Or anything where the semi-dangerous program is called
case "$1" in
	(foo|bar)
		"$@";;
	(baz)
		PATH="$OLDPATH" "$@";;
	(*)
		echo "wrap: $1 not allowed">&2;;
esac	
```

Please be warned that users may get the length of `startup` by `echo $LINENO`.
To avoid this, consider a read-only script to source in startup.

References
----------

* GNU bash manual 6.10, [Restricted Shell](http://www.gnu.org/software/bash/manual/html_node/The-Restricted-Shell.html).
* Node.js `child_process`, [child_process.spawn](https://nodejs.org/api/child_process.html#child_process_child_process_spawn_command_args_options).
