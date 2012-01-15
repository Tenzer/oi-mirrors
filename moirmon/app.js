#!/usr/bin/node

var fs = require("fs");
var http = require("http");

var configFile = fs.readFileSync("config.js");
var config = JSON.parse(configFile);
var repo;
repositories = [];


var getUpdateDate = function (pkgrepo) {
	var options = {
		host: pkgrepo.host,
		port: pkgrepo.port,
		path: "/" + pkgrepo.path + "/status/0/"
	};
	var request = http.get(options, function(response) {
		var data = "";
		
		response.on("data", function(chunk) {
			data += chunk;
		});
		
		response.on("end", function() {
			repositories.push(JSON.parse(data).repository);
			
			/*
			var lastUpdate = info.repository.publishers[pkgrepo.identifier]["last-catalog-update"];
			var pkgCount = info.repository.publishers[pkgrepo.identifier]["package-count"];
			var pkgVerCount = info.repository.publishers[pkgrepo.identifier]["package-version-count"];
			console.log(pkgrepo.host + "/" + pkgrepo.path + ": " + lastUpdate + " - " + pkgCount + " - " + pkgVerCount);*/
		});
	});
};

for (repo in config.repositories) {
	if (config.repositories.hasOwnProperty(repo)) {
		var repository = config.repositories[repo];
		
		getUpdateDate(repository);
		//console.log(getUpdateDate(repository));
	}
}
setTimeout(function() {console.log(repositories);}, 5000);
//getUpdateDate({"host": "pkg-1.dk.openindiana.org", "port": 80, "path": "dev", "identifier": "openindiana.org"});
