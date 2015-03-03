path = require("path")

module.exports = (grunt) ->
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  config =
    compiled: ".compiled"
    dist: "dist"
    doc: "doc"
    release:"release"
    src:"src"
    test:"test"

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    config:config
    coffee:
      files:
        cwd:"<%= config.src %>"
        src:"**/*.coffee"
        dest:"<%= config.compiled %>/src"
        ext:".js"
        expand:true
      test:
        cwd:"<%= config.test %>"
        src:"**/*.coffee"
        dest:"<%= config.compiled %>/test"
        ext:".js"
        expand:true
    copy:
      release:
        files:[{
          cwd:"<%= config.compiled %>/src"
          src:"**/*.js"
          expand:true
          dest:"<%= config.release %>"
        }]
    clean:[
      '<%=config.compiled%>'
      '<%=config.doc%>'
    ]
    karma:
      unit:
        configFile:"karma.conf.js"
    ngdocs:
      all:"<%= config.compiled %>/src/**/*.js"
      options: 
        scripts: ['angular.js']
        html5Mode: false
        title:"google-analytics Api"
    watch:
      options:
        livereload: true
      coffee:
        files:["src/**/*.coffee","test/**/*.coffee"]
        tasks:['coffee']
    concurrent:
      options:
        logConcurrentOutput: true
      docs:['connect:docs']
      sample:['watch','connect:sample']
      test:['watch','karma']
    connect: 
      options: 
        keepalive: true
        port:9000
      docs:
        options:
          base:['docs']
      sample:
        options:
          base:'./'

  grunt.registerTask('build',['clean','coffee'])
  grunt.registerTask('release',['build','copy:release'])
  grunt.registerTask('doc',['build','ngdocs','connect:docs'])
  grunt.registerTask('s',['build','concurrent:sample'])
  grunt.registerTask('t',['build','concurrent:test'])

  grunt.registerTask "default", ["build"]
  grunt.registerTask "r", ["release"]
  return 