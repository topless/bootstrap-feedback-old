module.exports = (grunt) ->
  require('load-grunt-tasks') grunt

  path = require 'path'

  config =
    connect_port: 8888
    livereload_port: 31415
    app: 'src'
    dist: 'dist'
    prod: 'prod'
    js: 'js'
    test: 'test'
    coffee: 'coffee'

  grunt.initConfig
    config: config

    wiredep:
      app:
        src: "#{config.app}/index.html"

    coffee:
      dist:
        expand: true
        cwd: config.app
        src: ['**/*.coffee']
        dest: config.dist
        ext: '.js'

      test:
        expand: true
        cwd: path.join config.test, config.coffee
        dest: path.join config.test, config.js
        src: ['**/*.coffee']
        ext: '.js'


    less:
      dist:
        options:
          paths: ['<%= config.app %>/style']
        files:
          '<%= config.dist %>/style/main.css': '<%= config.app %>/style/main.less'


    copy:
      dist:
        files: [
            expand: true
            cwd: config.app
            src: ['**/*.html']
            dest: config.dist
          ,
            src: "#{config.app}/static/icons.png"
            dest: "#{config.dist}/style/icons.png"
        ]


    jasmine:
      dist:
        src: '<%= config.dist %>/**/*.js'
        options:
          specs: '<%= config.test %>/<%= config.js %>/*_spec.js'


    watch:
      app:
        options:
          livereload: config.livereload_port
        files: '<%= config.app %>/**/*.{coffee,less}'
        tasks: ['coffee:dist', 'less:dist']

      static:
        options:
          livereload: config.livereload_port
        files: ['<%= config.app %>/*.html', '<%= config.app %>/**/*.html']
        tasks: ['copy:dist']

      test:
        options:
          livereload: config.livereload_port
        files: '<%= config.test %>/**/*.coffee'
        tasks: ['coffee:test', 'jasmine']


    open:
      dev:
        path: "http://localhost:#{config.connect_port}/"


    connect:
      server:
        options:
          port: config.connect_port
          hostname: '*'

    clean:
      dist: config.dist
      test: path.join config.test, config.js


  grunt.registerTask 'dist', ['clean:dist', 'wiredep', 'coffee:dist', 'less:dist', 'copy']
  grunt.registerTask 'test', ['dist', 'clean:test', 'coffee:test', 'jasmine']

  grunt.registerTask 'default', ['dist', 'connect', 'open', 'watch']
