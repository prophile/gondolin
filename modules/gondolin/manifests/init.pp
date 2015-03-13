class gondolin {
	$me = 'alynn'
	$real = 'Alistair Lynn'
	$email = 'arplynn@gmail.com'
	
	$home = "/home/$me"
	
	user { $me:
		ensure     => present,
		comment    => $real,
		managehome => true,
		groups     => ['sudo'],
		shell      => '/bin/sh',
		require    => Package['zsh']
	}
	
	# Some basic git configuration
	augeas { "set $me git config":
		lens    => 'Puppet.lns',
		incl    => "$home/.gitconfig",
		changes => ["set user/name '$real'",
					"set user/email '$email'",
					"set color/ui 'true'",
					"set diff/algorithm 'patience'",
					"set push/default 'simple'",
					"set alias/ca 'commit --amend'",
					"set alias/ff 'merge --ff-only'",
					"set alias/ffp 'pull --ff-only'",
					"set alias/dc 'diff --cached'",
					"set alias/br 'branch'",
					"set alias/s 'status'",
					"set alias/c 'commit'",
					"set alias/a 'add'",
					"set alias/d 'diff'",
					"set alias/i 'add --interactive'",
					"set alias/p 'add --patch'"],
		require => User[$me]
	}
	
	file { "$home/.zshrc":
		ensure => file,
		source => 'puppet:///modules/gondolin/zshrc',
		owner  => $me
	}
	
	file { "$home/.screenrc":
		ensure => file,
		source => 'puppet:///modules/gondolin/screenrc',
		owner  => $me
	}

    class { 'apt':
		always_apt_upgrade   => true,
		purge_sources_list   => true,
		purge_sources_list_d => true,
		purge_preferences    => true,
		purge_preferences_d  => true
	}
	
	apt::source { 'ubuntu':
		comment  => 'Multiverse Ubuntu package collection',
		location => 'http://archive.ubuntu.com/',
		repos    => 'main restricted universe multiverse'
	}
	
	Package {
		require => Apt::Source['ubuntu']
	}
	
	package { ['screen',
			   'nano',
			   'zsh',
			   'python', 'python-dev',
			   'python3', 'python3-dev',
			   'libyaml', 'libyaml-dev',
			   'libglfw3', 'libglfw3-dev',
			   'ruby-dev',
			   'curl', 'wget',
			   'irssi',
			   'iptables', 'traceroute']:
		ensure => latest
	}
	
	package { ['fpm', 'jekyll', 'travis']:
		ensure   => latest,
		provider => gem,
		require  => Package['ruby-dev']
	}
	
	# Steam
	apt::key { 'volvo':
		key        => 'B05498B7',
		key_server => 'keyserver.ubuntu.com'
	} ->
	apt::source { 'volvo':
		comment  => 'Valve Software repo, for Steam',
		location => 'http://repo.steampowered.com/steam/',
		release  => 'precise',
		repos    => 'steam'
	}
	package { 'steam':
		ensure  => latest,
		require => Apt::Source['volvo']
	}
	
	# Atom
	$atom_release = 'v0.187.0'
	exec { 'download Atom':
		command => "wget -N 'https://github.com/atom/atom/releases/download/$atom_release/atom-amd64.deb'",
		cwd     => '/var',
		require => Package['wget']
	} ~>
	package { 'atom':
		ensure   => latest,
		provider => dpkg,
		source   => '/var/atom-amd64.deb'
	}
	
	# Chrome
	apt::key { 'chrome':
		key_source => 'https://dl-ssl.google.com/linux/linux_signing_key.pub'
	} ->
	apt::source { 'chrome':
		comment  => 'Google Chrome repository',
		location => 'http://dl.google.com/linux/chrome/deb/',
		release  => 'stable',
		repos    => 'main'
	}
	
	package { 'google-chrome-stable':
		ensure  => latest,
		require => Apt::Source['chrome']
	}
	
	# Spotify
	apt::key { 'spotify':
		key        => '94558F59',
		key_server => 'keyserver.ubuntu.com'
	} ->
	apt::source { 'spotify':
		comment  => 'Spotify repository',
		location => 'http://repository.spotify.com',
		release  => 'stable',
		repos    => 'non-free'
	}
	
	package { 'spotify-client':
		ensure  => latest,
		require => Apt::Source['spotify']
	}
}
