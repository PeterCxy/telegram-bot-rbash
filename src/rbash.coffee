{spawn} = require 'child_process'

exports.exec = (rbash, path, cmds, callback) ->
	if isBomb cmds
		callback 'Potential fork bomb detected.', 23333
	else if hasIO cmds
		callback 'Potential I/O access denied', 23333
	else

		# NOTICE: Before using this
		# PLEASE make sure the default $PATH
		# Of the current user running 'node'
		# Is set to a limited dir!
		# DO NOT put any dangerous commands there!
		bash = spawn rbash,
			cwd: '/var/empty'
			env:
				'PATH': path

		opt = ''

		bash.stdout.on 'data', (data) =>
			opt += data
	
		bash.stderr.on 'data', (data) =>
			opt += data
	
		bash.on 'exit', (code) =>
			callback opt, code

		# TODO
		# make an configurable limited 'cat' command
		# do not let it read anything outside its own limit
		bash.stdin.write "readonly EDITOR\nreadonly PAGER\n#{cmds}\nexit 0\n"

		# Maximum execution time is 500ms
		setTimeout =>
			bash.stdin.end()
			bash.kill()
		, 500

contains = (str, sub) ->
	(str.indexOf sub) > -1

isBomb = (cmd) ->
	if (contains cmd, 'ulimit') or (contains cmd, '|') or (contains cmd, '&') or (contains cmd, '\\x7c') or (contains cmd, '\\x26')
		console.log 'BOOM'
		true
	else
		# Should do more checks here
		false
	
hasIO = (cmd) ->
	if (contains cmd, '<') or (contains cmd, '/*')
		true
	else
		false
