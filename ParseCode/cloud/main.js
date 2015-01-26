Parse.Cloud.beforeSave("Response", function(request, response) {
	var myInnerObject = request.object
	if (myInnerObject.get("question") != null) {
		myInnerObject.set("questionId", myInnerObject.get("question").id);
	}
	response.success();
});
