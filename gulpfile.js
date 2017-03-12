/*jslint node: true, sloppy: true*/

var gulp = require('gulp');
var server = require('gulp-express');
var rimraf = require('rimraf');
var bower = require('gulp-bower');
var watch = require('gulp-watch');
var exec = require('child_process').exec;

gulp.task('default', function () {
    server.run(['index.js']);
    gulp.watch(['index.js'], function () {
        console.log('Restarting express');
        server.run();
    });
});

gulp.task('bower', function () {
    return rimraf('public/dist', function () {
        bower('./bower_components')
            .pipe(gulp.dest('public/dist/'));
    });
});

gulp.task('bower-watch', function () {
    exec('gulp bower');
    watch('bower.json', function () {
        rimraf('public/dist', function () {
            bower('./bower_components')
                .pipe(gulp.dest('public/dist/'));
        });
    });
});
