$(document).ready(function() {
  $('.service-list-div ul li').each(function() {
		hook_arrow = $(this).children().attr('id').replace(/-toggle/, "-arrow");
		$('.service-arrows').append('<div class="right-arrow hidden" id="' + hook_arrow + '">&nbsp;</div>');
	});
	$('.service-arrows > div.right-arrow:first').removeClass('hidden');
	$('li.string:not([class~=add_url]):not([class~=add_email]) input[type=text]').tipsy({trigger: 'focus', gravity: 'w', fade: true });
	$('li.boolean:not([class~=active_checkbox]) > label').tipsy({trigger: 'focus', gravity: 'w', fade: true, title: function() { return $(this).find('input[type=checkbox]').attr('title'); } });
	$('li.boolean[class*=active_checkbox] > label').tipsy({trigger: 'focus', gravity: 'w', fade: true, fallback: 'Activate this hook?' });
});

$('div.service-list-div ul li').live('click', function () {
	hook_link = '#' + $(this).children().attr('id');
	// hook_link_li = $(hook_link).parent();
	hook_div = hook_link.replace(/-toggle/, "");
	hook_arrow = hook_link.replace(/-toggle/, "-arrow");
	$('.service-arrows > div.right-arrow:not(.hidden)').addClass('hidden');
	$('.service-list-div ul > li.current').removeClass('current');
	$(hook_arrow).removeClass('hidden');
	$(hook_link).parent().addClass('current');
	$('div.hook:visible').hide();
	$(hook_div).show();
});

function remove_field(t) {
	if (confirm('Are you sure you want to delete this hook?')) {
		$(t).parent().remove();
	} else {
		return;
	}
}
function add_field(t) {
	p = $(t).parent().parent();
	h = $('li#array_urls__input:last').html();
	$('<li class="string required" id="array_urls__input">' + h + '</li>').insertBefore($('li.add_url')).children('[type=text]').attr('value', '');
}

function remove_email(t) {
	if (confirm('Are you sure you want to delete this email?')) {
		$(t).parent().remove();
	} else {
		return;
	}
}
function add_email(t) {
	p = $(t).parent().parent();
	h = $('li#hook_emails__input:last').html();
	$('<li class="string required" id="hook_emails__input">' + h + '</li>').insertBefore($('li.add_email')).children('[type=text]').attr('value', '');
}
// TESTING HOOKS
$('a.test-hook').live('click', function () {
	link = $(this);
	link.addClass('selected');
	link.addClass('disabled');
	link.disabled = true;
	loader = "#" + link.attr('id').replace(/_link$/, '_loading');
	$(loader).show();
	$.get(link.attr('href'), function(data) {
		link.removeClass('selected');
		link.removeClass('disabled');
		$(loader).hide();
	});
	return false;
});