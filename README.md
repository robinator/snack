                            _
       ___ _ __   __ _  ___| | __
      / __| '_ \ / _` |/ __| |/ /
      \__ \ | | | (_| | (__|   <
      |___/_| |_|\__,_|\___|_|\_\
      

 - Snack is a small (<= 150 lines) framework for building static websites.
 - Snack is built on [tilt](http://github.com/rtomayko/tilt) and should render any template tilt can.
 - It compiles these templates into static html, css, and javascript.
 - It also comes with a rack-based server for development.

Getting Started
=================
1. Install snack at the command prompt if you haven't yet:

        gem install snack

2. At the command prompt, create a new snack application:

        snack new myapp

   where "myapp" is the application name.

3. Start the web server:

        snack serve myapp

4. Go to http://localhost:9393/ and you'll see:

        "Hello from snack!"

5. When you're ready to export the site into html, use:

        snack build myapp

   You should see a new directory, _output, with your site in it.

Views
================
## Layouts
## Partials
## Capture



Todo
================
- better documentation
- better error messages for parse template errors (sass)

Inspiration
=============================================
 - http://github.com/rtomayko/tilt
 - http://github.com/staticmatic/staticmatic
 - http://github.com/blahed/frank
 - http://github.com/josh/stagecoach
 - http://github.com/tdreyno/middleman
 - http://github.com/mdub/pith