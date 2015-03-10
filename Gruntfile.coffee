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
    concat:
      all:
        src:['<%= config.release %>/analytics.js','<%= config.release %>/**/*.js','!<%= config.release %>/check/*.js','!<%= config.release %>/directives/time.js']
        dest:"<%= config.release %>/google-analytics.js"
    clean:[
      '<%=config.compiled%>'
      '<%=config.doc%>'
      '<%=config.release%>'
    ]
    bump:
      options:
        files:['package.json','bower.json']
        commitFiles:['-a']
        pushTo:'gitlab'
    karma:
      unit:
        configFile:"karma.conf.js"
      backgrund:
        configFile:"karma.conf.js"
        options:
          singleRun:true
      release:
        configFile:"karma.conf.js"
        options:
          singleRun:true
          files:[
            'bower_components/angular/angular.js',
            'bower_components/angular-ui-router/release/angular-ui-router.js',
            'bower_components/angular-mocks/angular-mocks.js',
            'release/google-analytics.js'
          ]
    removelogging:{
      dist:{
        src:"<%= config.compiled %>/src/**/*.js"
        options:{
          namespace:["console","\\$log"]
          method:["log"]
        }
      }
    }
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
      test:['watch','karma:unit']
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
  grunt.registerTask('rs',['build','karma:backgrund','removelogging','copy:release','concat'])

  grunt.registerTask('release',['build','karma:backgrund','removelogging','copy:release','concat','karma:release','bump'])
  grunt.registerTask('doc',['build','ngdocs','connect:docs'])
  grunt.registerTask('s',['build','concurrent:sample'])
  grunt.registerTask('t',['build','concurrent:test'])

  grunt.registerTask "default", ["build"]
  grunt.registerTask "r", ["release"]
  return 