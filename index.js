// Modules
var express = require('express');
var request = require('request');
var fs = require('fs');
var bodyParser = require('body-parser');
var cookieParser = require('cookie-parser');

var app = express();
var server = app.listen(process.env.TESTPORT, function() { console.log("Express listening on port " + process.env.TESTPORT); });
var io = require('socket.io').listen(server);

// Global constants
const STATE_LENGTH = 32; // Length of random state value used when retrieving oauth token
const STATE_RETURN_LENGTH = 16; // Length of randoms tate value used when retieving oauth token to return

// Global variables
var currentOauthConnections = [];

// Express
app.use(express.static('public'))
app.set('views', './views');
app.set('view engine', 'pug');
app.use(bodyParser.json());	// to support JSON-encoded bodies
app.use(bodyParser.urlencoded({extended: true}));	// to support URL-encoded bodies
app.use(cookieParser()); // to views cookies stored on browser

// Returns homepage
app.get('/', function(req, res) {
	res.render('index', {showToken: req.query.showToken, token: req.cookies.token});
	console.log(req.cookies.token);
});

// Returns page to begin authorization process
app.get('/authorize', function(req, res) {
	res.render('authorize');
});

// Gets new auth token and saves to localStorage
app.post('/normal_auth', function(req, res) {
	currentOauthConnections.push(new redditOauth(STATE_LENGTH));
	res.redirect(currentOauthConnections[currentOauthConnections.length - 1].build());
});

// Returns new auth token
app.post('/get_token', function(req, res) {
	currentOauthConnections.push(new redditOauth(STATE_RETURN_LENGTH));
	res.redirect(currentOauthConnections[currentOauthConnections.length - 1].build());
});

// Callback for reddit oauth
// Retrieves token
app.get('/authorize_callback', function(req, res) {
	if(req.query.state.length == STATE_RETURN_LENGTH) {
		res.render('index', {showToken: true, token: req.query.code});
	} else {
		request.post('https:/\/www.reddit.com/api/v1/access_token', {
			'auth': {
				'user': JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).client_id,
				'pass': JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).secret
			},
			'form' : {
				'grant_type': 'authorization_code',
				'code': req.query.code,
				'redirect_uri': JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).redirect_uri
			}
		}, function(error, response, body) {
			body = JSON.parse(body);
			Object.keys(body).forEach(function(key) {
				res.cookie(key, body[key]);
			});
			res.redirect('/');
		});
	}
});

app.post('/authorize_callback', function(req, res) {
	console.log(req.body.token);
	request.post('https:/\/www.reddit.com/api/v1/access_token', {
		'auth': {
			'user': JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).client_id,
			'pass': JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).secret
		},
		'form' : {
			'grant_type': 'authorization_code',
			'code': req.body.token,
			'redirect_uri': JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).redirect_uri
		}
	}, function(error, response, body) {
		console.log(body);
		body = JSON.parse(body);
		Object.keys(body).forEach(function(key) {
			res.cookie(key, body[key]);
		});
		res.redirect('/');
	});
});

// Removes cookie token to logout
app.post('/logout', function (req, res) {
	res.clearCookie('access_token');
});

// Returns page to sub feed
app.get('/r/:subreddit', function(req, res) {
	res.render('redirect_sub');
});

app.post('/r/:subreddit', function(req, res) {
	console.log('Hello');
	res.end();
	res.render('feed', {
		'title': req.params.subreddit,
		'subs': ['Frontpage'],
		'posts': [
			{
				'score': '9,012',
				'title': 'What would be the dumbest item to have a "buy one get one free" promotion?',
				'user': 'BretHartsSpandex',
				'time': '7 hours ago'
			}
		]
	});
});

// Use Sockets for communicating reddit token
io.on('connection', function(socket) {
	console.log('Connection');

	// Reddit API - Identity
	socket.on('identity', function(token) {
		request.get('https://oauth.reddit.com/api/v1/me', {
			'auth': {
				'bearer': JSON.parse(token).access_token
			},
			'headers': {
				'User-Agent': 'request'
			}
		}, function(error, response, body) {
			console.log('SocketIO Request - Identity');
			socket.emit('identity', body);
		});
	});


	// Check validity of Reddit token
	socket.on('check_token', function(token) {
		console.log('Checking token validity...');
		request.get('https://oauth.reddit.com/api/v1/me', {
			'auth': {
				'bearer': token
			},
			'headers': {
				'User-Agent': 'request'
			}
		}, function(error, response, body) {
			console.log(body);
			if(!JSON.parse(body).name) {
				console.log('Token: Invalid');
				socket.emit('check_token', false);
			} else {
				console.log('Token: Valid');
				socket.emit('check_token', true);
			}
		});
	});
});

function checkOauthState(query) {
	for(var i in currentOauthConnections) {
		if(currentOauthConnections[i].state == query) {
			var currentOauth = currentOauthConnections[i];
			currentOauthConnections.splice(i, 1);
			return currentOauth;
		}
	}
	return false;
}

// Class for reddit oauth
function redditOauth(stateLength) {
	this.client_id = JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).client_id;
	this.response_type = "code";
	this.state = generateRandomString(stateLength);
	this.redirect_uri = JSON.parse(fs.readFileSync( __dirname + '/client.json', 'utf8')).redirect_uri;
	this.duration = "permanent";
	this.scope = [
		"edit",
		"history",
		"identity",
		"mysubreddits",
		"save",
		"submit",
		"subscribe",
		"vote"
	];

	this.build = function() {
		var scopeString  = "";
		for(var i in this.scope) {
			if(i != 0) {
				scopeString += "%20";
			}
			scopeString += this.scope[i];
		}

		return "https:/\/www.reddit.com/api/v1/authorize?client_id=" + this.client_id + "&response_type=" + this.response_type + "&state=" + this.state + "&redirect_uri=" + encodeURIComponent(this.redirect_uri) + "&duration=" + this.duration + "&scope=" + scopeString;
	};
}

// Generates a string with a speciified length
function generateRandomString(stringLength) {
	var possibleChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	var text = "";

	for(var i = 0; i < stringLength; i++) {
		text += possibleChars.charAt(Math.floor(Math.random() * possibleChars.length));
	}

	return text;
}
