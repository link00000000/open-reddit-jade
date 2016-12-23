var gulp = require('gulp');
var server = require('gulp-express');
// var sass = require('gulp-sass');

// gulp.task('styles', function() {
// 	gulp.src('sass/*.scss')
// 		.pipe(sass().on('error'), sass.logError)
// 		.pipe(gulp.dest('./public/css/'));
// });

gulp.task('default', function() {
	server.run(['index.js']);
	gulp.watch(['index.js'], function() {
		console.log('\n\n\nRestarting express');
		server.run();
	});
	// gulp.watch('sass/*.scss', ['styles']);
});
