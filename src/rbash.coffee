{spawn} = require 'child_process'

exports.exec = (rbash, path, cmds, callback) ->
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

	bash.stdin.write cmds + '\nexit 0\n'

	# Maximum execution time is 500ms
	setTimeout =>
		bash.stdin.end()
		bash.kill()
	, 500
