
(function() {
jasmine.FormalReporter = function(doc) {
   this.document = doc || document;
   this.suiteDivs = {};
   this.logRunningSpecs = false;
 };
 
 jasmine.FormalReporter.prototype.createDom = function(type, attrs, childrenVarArgs) {
 };
 
 jasmine.FormalReporter.prototype.reportRunnerStarting = function(runner) {
   var showPassed, showSkipped;
 
   var suites = runner.suites();
   for (var i = 0; i < suites.length; i++) {
     var suite = suites[i];
   }
 
   this.startedAt = new Date();
 
   var self = this;
 };
 
 jasmine.FormalReporter.prototype.reportRunnerResults = function(runner) {
 };
 
 jasmine.FormalReporter.prototype.reportSuiteResults = function(suite) {
 };
 
 jasmine.FormalReporter.prototype.reportSpecStarting = function(spec) {
 };
 
 jasmine.FormalReporter.prototype.reportSpecResults = function(spec) {
   var results = spec.results();
   var status = results.passed() ? 'passed' : 'failed';
 
     var k = "#test_" + spec.description.split("::")[0]
     if (status == "passed") {
         //$(k).css("background-color", "rgba(0,100,0,0.3)");
         $(k).before("<span style='background-color:rgba(0,150,0,0.5)'> <span style='color:rgb(255,255,255);font-weight:bold'>PASSED</span> </span> ")
     } else {
         $(k).before("<span style='background-color:rgba(200,0,0,0.5)'> <span style='color:rgb(255,255,255);font-weight:bold'>FAILED</span> </span> ")
     }
 };
 
 jasmine.FormalReporter.prototype.log = function() {
 };
 
 jasmine.FormalReporter.prototype.getLocation = function() {
   return this.document.location;
 };
 
 jasmine.FormalReporter.prototype.specFilter = function(spec) {
   var paramMap = {};
   var params = this.getLocation().search.substring(1).split('&');
   for (var i = 0; i < params.length; i++) {
     var p = params[i].split('=');
     paramMap[decodeURIComponent(p[0])] = decodeURIComponent(p[1]);
   }
 
   if (!paramMap.spec) {
     return true;
   }
   return spec.getFullName().indexOf(paramMap.spec) === 0;
 };
 
})();