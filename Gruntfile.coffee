path = require("path")

module.exports = (grunt) ->
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  
  config =
    compiled: ".compiled"
    dist: "dist"
    doc: "doc"
    release:"release"
    src:"src"

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    config:config
    coffee:
      files:
        cwd:"<%= config.src %>"
        src:"**/*.coffee"
        dest:"<%= config.compiled %>"
        ext:".js"
        expand:true
    copy:
      release:
        files:[{
          cwd:"<%= config.compiled %>"
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
      all:"<%= config.compiled %>/**/*.js"
      options: 
        scripts: ['angular.js']
        html5Mode: false
        title:"google-analytics Api"
    connect: 
      options: 
        keepalive: true
        port:9000
      server:
        options:
          base:['docs']
  grunt.registerTask('build',['clean','coffee'])
  grunt.registerTask('release',['build','copy:release'])
  grunt.registerTask('doc',['build','ngdocs','connect'])
  grunt.registerTask "default", ["build"]
  grunt.registerTask "r", ["release"]
  return 