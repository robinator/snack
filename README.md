													_ 
		 ___ _ __   __ _  ___| | __
		/ __| '_ \ / _` |/ __| |/ /
		\__ \ | | | (_| | (__|   < 
		|___/_| |_|\__,_|\___|_|\_\
		
	# Snack is a small framework for building static websites.
	# It can compile these templates into static html, css, and javascript.
	# It also comes with a rack-based server for development.
	
Todo
=============================================
*For 0.1*

- documentation
- test suite
  - only haml, sass, coffee, erb
- add Snack::Builder to export to static site
- gem stuff
- git repo
- warning: multiple values for a block parameter (0 for 1) for yield_content

*For Later*

- better error messages for parse template errors (sass)
  - layout not found, etc
- tests for other templates
 < From Rack::Server for server stuff? - see camping http://github.com/hank/camping/blob/master/lib/camping/server.rb
- replace haml view stuff with haml::more gem?_

Inspiration
=============
 - http://github.com/rtomayko/tilt
 - http://github.com/staticmatic/staticmatic
 - http://github.com/blahed/frank
 - http://github.com/josh/stagecoach
 - http://github.com/tdreyno/middleman
 - http://github.com/mdub/pith