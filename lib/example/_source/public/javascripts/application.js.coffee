$(document).ready () ->
	$('a.env').bind 'click', () ->
		$('#settings').slideToggle 'fast'