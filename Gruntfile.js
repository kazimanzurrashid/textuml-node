module.exports = function(grunt) {
  grunt.initConfig({
    watch: {
      scripts: {
        files: ['public/javascripts/**/*.coffee'],
        tasks: ['coffee']
      }
    },
    coffee: {
      options: {
        bare: true
      },
      files: {
        expand: true,
        cwd: 'public/javascripts/',
        dest: 'public/javascripts',
        src: '**/*.coffee',
        ext: '.js'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-coffee');
};