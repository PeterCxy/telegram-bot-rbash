{spawn} = require 'child_process'

exports.exec = (rcfg, cmds, callback) ->
	# Default Values
	dcfg = {
		time: 500			# Wait for 500ms
		bash: '/bin/bash'	# Just a Regular bash
		args: [ '-r' ]		# With the restricted option on
		spawn:				# Everything passed to spawn
			cwd: '/tmp/botsh'	# Take it elsewhere
			env:			# And a simple environment
				'PATH': ''	# And yes, no PATH at all.
		startup:			# Default string at startup -- too lazy to use rc.
			". /etc/profile\n
			readonly PAGER=cat EDITOR=true\n
			export PAGER EDITOR\n
			ulimit(){ echo Fuck ya; }\n
			readonly -fx ulimit"
	}

	# ES6 big law good and screw you stupid coffeescript for loops!
	dcfg.keys().foreach apply_default

	bash = spawn rcfg.bash, rcfg.args, rcfg.spawn

	bash.stdout.on 'data', (data) =>
		out += data

	bash.stderr.on 'data', (data) =>
		out += 'E ' + data

	bash.on 'exit', (code) =>
		callback out, code

	bash.stdin.write rcfg.startup + "\n#{cmds}\n"

	# If time outs, kill.
	setTimeout =>
		bash.stdin.end()
		bash.kill()
	, time
	
# key: string
# Applys the default value on typeof mismatch.
apply_default = (key) ->
	key_expanded = key.split('.')
	defval = get_prop(dcfg, key_expanded)
	cfgval = get_prop(rcfg, key_expanded)
	d_type = typeof defval
	c_type = typeof cfgval
	
	if d_type != c_type
		set_prop (key_expanded, defval)
		return

	# if d_type == 'object'
		# defval.keys().foreach (k) ->
			# apply_default "${#key}.${#k}"

# key: array
set_prop = (key, val) ->
	# Walk through the keys and do the assignment
	t = undefined;
	m = undefined;
	p = key.pop()
	while l.length
		t = key[m = l.shift()] or (key[m] = new Object())
	t[p] = val

# key: array		
get_prop = (obj, key) ->
	t = obj
	m = undefined;
	p = key.pop()
	while l.length
		t = key[m = l.shift()] or return
	t[p]
