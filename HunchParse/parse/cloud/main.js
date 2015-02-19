var Mandrill = require('mandrill');
Mandrill.initialize('Aiqzv_Gi1IKKatKYtLrlFg');

Parse.Cloud.beforeSave("Response", function(request, response) {
	var object = request.object;
	
	if (object.get("question") != null) {
		object.set("questionId", object.get("question").id);
	}
	
	response.success();
});

// PUSH

Parse.Cloud.afterSave("Response", function(request, response) {
	var questionId = request.object.get("question").id;
	var query = new Parse.Query("Question");
	
	query.get(questionId).then(function (question) {
		var user = question.get("user");
		
		var pushQuery = new Parse.Query(Parse.Installation);
		pushQuery.equalTo("user", user);
		
		Parse.Push.send({
			where: pushQuery,
			data: {
				alert: "Your question just received an answer!",
				badge: "Increment",
				sound: "hmmm.aiff"
  			}
		}, {
			success: function() {
				console.log("Push sent to " + user.id);
  		 	},
  			error: function(error) {
  				console.log("Push failed to send to " + user.id);
  			}
		});
	});
});

// ABUSE

Parse.Cloud.beforeSave("Abuse", function(request, response) {
	var questionId = request.object.get("question").id;
	var query = new Parse.Query("Question");
	
	query.get(questionId).then(function (question) {
		var object = new Parse.Object("Response");
		object.set("question", question);
		object.set("user", request.user);
		
		object.save(null, {
		  success: function(object) {
		    response.success();
		  },
		  error: function(object, error) {
		    response.error("Count not save response object.");
		  }
		});
	});
});

Parse.Cloud.afterSave("Abuse", function(request, response) {
	var questionId = request.object.get("question").id;
	var query = new Parse.Query("Question");
	
	query.get(questionId).then(function (question) {
		var message = "Abuse has been reported by "
				+ request.user.get("username")
				+ " for question:\n"
				+ question.get("text")
				+ "\n\nView: https://www.parse.com/apps/hunch--4/collections#class/Abuse"
			
		Mandrill.sendEmail({
			message: {
		    	text: message,
				subject: "Hunch Abuse Report",
				from_email: "hunch@parseapp.com",
				from_name: "Hunch Administrator",
				to: [{
					email: "anthony.picciano@gmail.com",
				}]
		    },async: true
			},{
			success: function(httpResponse) {
				console.log("Warning email sent.");
			},
		  	error: function(httpResponse) {
				console.log("Warning email failed to send.");
			}
		});
	});
});