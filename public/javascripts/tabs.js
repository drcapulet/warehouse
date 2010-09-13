// HIDE EVERYTHING
// FORCE THE TABLE HEIGHT
height = ($(window).height())/1.42;
width = $("div.sourcecode").width() - 250;
$("div.browse div#tree div#treecont").css({'height' : height - 28});
$("div.browse div#source pre.viewsource").css({'height' : height, 'width' : width});
// TREE CLICKERS
$("#tree #treecont ul li.tree a").live("click", function() {
	p = $(this).parent();
	if (p.hasClass("opened")) {
		p.removeClass("opened").next().hide();
	} else {
		p.addClass("opened").next().show();
	}
	return false;
});

// FILE CLICKS
$("#tree #treecont ul li.file a").live("click", function() {
	$(this).showSource();
	return false;
});
// TAB CLICKS
$("div.sourcecode div.controls div#tabs ul li").live("click", function() {
	$(this).showSource();
	return false;
});
// CLOSE TAB
$("div.sourcecode div.controls div#tabs ul li span.close").live("click", function() {
	$("div.sourcecode div#source pre[path='" + $(this).parent().attr('path') + "']").remove();
	$("div.sourcecode div#source pre#blank-source").show();
	$("div.sourcecode div.controls div#tabs ul li[path='" + $(this).parent().attr('path') + "']").remove();
	$("div.sourcecode div.sub-controls").empty();
	$("div.sourcecode div.controls div#tabs ul li:last").click();
	return false;
});


jQuery.fn.showSource = function() {
    var e = $(this[0])
		var path = e.attr('path');
		var epath = path.replace(/^\//,"")
		$("div.sourcecode div#source > *").hide(); // Hide all code
		$("div.sourcecode div.controls div#tabs ul li.selected").removeClass('selected'); // Remove the selected class from tabs
		
		// Checking for an existing tab
		if ($("div.sourcecode div.controls div#tabs ul li[path='" + path + "']").length) {
			$("div.sourcecode div.controls div#tabs ul li[path='" + path + "']").addClass('selected');
		} else { 
			// Creeate the Tab
	 		$("div.sourcecode div.controls div#tabs ul").append('<li path="' + path + '" class="selected">' + path.split('/')[path.split('/').length-1] + '<span class="close">x</span></li>');
			url = '/' + $('div.sourcecode').attr('repo') + '/tree/' + $('#repotree').attr('value') + '/hil' + path;
			$.get(url, function(data){
		    $("div.sourcecode div#source").append("<pre class='viewsource' path='" + path + "' style='height:" + height + "px; width:" + width + "px;'><code>" + data + "</code></pre>");
		  });
		}
		
		$("div.sourcecode div.sub-controls span#filename").html(epath);
		$("div.sourcecode div#source > pre[path='" + path + "']").show();
};