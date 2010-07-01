$(document).ready(function() {
	// HOOK LIST STYLING
  $('.service-list-div ul li').each(function() {
		hook_arrow = $(this).children().attr('id').replace(/-toggle/, "-arrow");
		$('.service-arrows').append('<div class="right-arrow hidden" id="' + hook_arrow + '">&nbsp;</div>');
	});
	$('.service-arrows > div.right-arrow:first').removeClass('hidden');
	// TIPSY
	$('li.string:not([class~=add_url]):not([class~=add_email]) input[type=text]').tipsy({trigger: 'focus', gravity: 'w', fade: true });
	$('li.boolean:not([class~=active_checkbox]) > label').tipsy({trigger: 'focus', gravity: 'w', fade: true, title: function() { return $(this).find('input[type=checkbox]').attr('title'); } });
	$('li.boolean[class*=active_checkbox] > label').tipsy({trigger: 'focus', gravity: 'w', fade: true, fallback: 'Activate this hook?' });
	$('a.disabled').tipsy({trigger: 'focus', gravity: 'w', fade: true, fallback: 'You need to activate the hook before you can test it!' });
	$('a.disabled').attr('disabled', 'disabled');
	// ALLOW URL PARAMS TO SHOW A CERTAIN HOOK
	if (document.URL.match(/#[A-Za-z_]+/)) {
		hook_link = document.URL.match(/#[A-Za-z_]+/) + "-toggle";
		$(hook_link).click();
	}
	// AJAX hook form submit
	$('form.hook-form').bind('submit', function() {
		id = $(this).attr('id');
		messages_id = "#" + id.replace(/_form/, "_messages");
		loading_id = "#" + id.replace(/_form/, "_loading");
		toggle_id = "#" + id.replace(/_form/, "-toggle");
		toggle = $(toggle_id).parent();
		test_id = "#" + id.replace(/_form/, '_link');
		if (id.replace(/_form/, "") == "post_receive") {
			submit = $(this).find("input#array_submit");
		} else {
			submit = $(this).find("input#hook_submit");
		}
		// DISABLING BUTTONS
		disable_g_button(submit);
		disable_g_button($(test_id));
		disable_g_button($('div.hook:visible').find('a.disable_this_link'));
		if (id.replace(/_form/, "") == "post_receive") { disable_g_button($("#add_post_receive_link")); }
		if (id.replace(/_form/, "") == "email") { disable_g_button($("#add_email_link")); }
		$(loading_id).show(); // SHOW THE LOADER
		$(messages_id).empty().show(); // EMPTY MESSAGES
		// Now we find whether the hook is enabled
		if (id.replace(/_form/, "") == "post_receive" || id.replace(/_form/, "") == "email") {
			// find the count of emails/urls
			objects = $(this).serializeArray()
			items = objects.filter(function (element, index, array) {
				if (element.name == "array[urls][]" || element.name == "hook[emails][]") {
					if (element.value != "") { return element; }
				}
			});
			active = (items.length > 0);
		} else {
			active = $(this).find('input#hook_active').attr('checked');
		}
		$.post($(this).attr('action'), $(this).serialize(), function(data) {
			$(messages_id).html(data);
			if (active) {
				if (id.replace(/_form/, "") == "post_receive") {
					toggle.find('span.count').html(items.length);
				}
				enable_g_button($(test_id));
				toggle_link_status(toggle, true);
			} else {
				if (id.replace(/_form/, "") == "post_receive") {
					toggle.find('span.count').html('0');
				}
				toggle_link_status(toggle, false);
			}
			$(messages_id).wait(5000).fadeOut();
			$(loading_id).hide();
			// RE-ENABLE BUTTONS
			enable_g_button(submit);
			enable_g_button($('div.hook:visible').find('a.disable_this_link'));
			if (id.replace(/_form/, "") == "post_receive") { enable_g_button($("#add_post_receive_link")); }
			if (id.replace(/_form/, "") == "email") { enable_g_button($("#add_email_link")); }
		});
		return false;
	});
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

$('div.flash-notice.mini span.close').live('click', function () {
	$(this).parent().hide();
});

function remove_field(t) {
	if (confirm('Are you sure you want to delete this url?')) {
		$(t).parent().remove();
	} else {
		return;
	}
}
function add_field(t) {
	p = $(t).parent().parent();
	h = $('li#array_urls__input:last').html();
	$('<li class="string required" id="array_urls__input">' + h + '</li>').insertBefore($('li.add_url:last')).children('[type=text]').attr('value', '');
}

function add_link_html(h) { 
	$('div.new_url_field_html').before(h);
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

function add_email_html(h) {
	$('div.new_email_field_html').before(h);
}
// TESTING HOOKS
$('a.test-hook').live('click', function () {
	link = $(this);
	if (link.attr('disabled') && link.attr('disabled') == 'disabled')  {
	} else {
		disable_g_button(link);
		loader = "#" + link.attr('id').replace(/_link$/, '_loading');
		$(loader).show();
		$.get(link.attr('href'), function(data) {
			enable_g_button(link);
			$(loader).hide();
		});
	}
	return false;
});
// DISABLE/ENABLE links/buttons
function disable_g_button(b) {
	b.addClass('selected');
	b.addClass('disabled');
	b.attr('disabled', 'disabled');
}
function enable_g_button(b) {
	b.removeClass('selected');
	b.removeClass('disabled');
	b.removeAttr('disabled');
}
// TOGGLE LINKS ACTIVE/INACTIVE
function toggle_link_status(l, active) {
	if (active) {
		if (l.hasClass('service_inactive')) { l.removeClass('service_inactive'); }
		l.addClass('service_active');
	} else {
		if (l.hasClass('service_active')) { l.removeClass('service_active'); }
		l.addClass('service_inactive');
	}
}
// WAIT PLUGIN
$.fn.wait = function(time, type) {
    time = time || 1000;
    type = type || "fx";
    return this.queue(type, function() {
        var self = this;
        setTimeout(function() {
            $(self).dequeue();
        }, time);
    });
};