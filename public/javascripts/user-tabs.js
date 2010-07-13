$(document).ready(function() {
	$('.edit-div').hide();
	$('#personal_info').show();
	$("li.password input").chromaHash({bars: 3, salt:"7be82b35cb0199120eea35a4507c9acf", minimum:6});
	// if (document.URL.match(/#[A-Za-z_]+/)) {
	// 	div = document.URL.match(/#[A-Za-z_]+/) + "";
	// 	$(div).show();
	// } else { $('#personal_information').show(); }
	$('div#admin-nav-bar ul li a').live('click', function () {
		$('.edit-div:visible').hide();
		$('div#admin-nav-bar ul li.selected').removeClass('selected');
		$(this).parent().addClass('selected');
		$($(this).attr('href')).show();
	});
});