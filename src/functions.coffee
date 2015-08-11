exports.name = 'rbash'
exports.desc = 'bash executor with restricted permissions'

exports.setup = (telegram, ..., server, _) ->
	pkg = require '../package.json'

	[
		cmd: 'bash'
		args: '[exec|help]'
		desc: 'exec: execute bash script. Max execution time is 500ms.'
		num: 1
		opt: 1
		act: (msg, cmd) =>
			if cmd == 'help'
				# TODO
				telegram.sendMessage msg.chat.id, 'help'
			else if msg.chat.title? and msg.chat.title.startsWith '#'
				telegram.sendMessage msg.chat.id, 'bash disabled in this group.'
			else
				server.grabInput msg.chat.id, msg.from.id, pkg.name, 'bash'
				telegram.sendMessage msg.chat.id, 'The Black Magic! Send me the script you want to execute.', msg.message_id
	]

exports.input = (cmd, msg, telegram, ..., server, config) ->
	# Release the input anyhow
	server.releaseInput msg.chat.id, msg.from.id

	if cmd is 'bash'
		bash = require './rbash'
		config rbash ||= new Object();
		bash.exec config.rbash, msg.text, (res, code) =>
			exit = if code is null then "Timed out." else "Exit with ${#code}"
			# Trunctate the data here
			t = res.split("\n")
			t.length = 20
			res = t.join("\n")
			telegram.sendMessage msg.chat.id, "#{res}\n#{exit}", msg.message_id
