$(document).ready(function(){

	$('#search-submit').click(function(e){
		e.preventDefault();
		$('.results').empty();
		$('i.fa-spinner').removeClass('hidden');
		$(this).attr('disabled', true);
		query = $('form#search-form').serialize();
		$.post('/search', query, function(data){
			$('.results').append(data)
			$('i.fa-spinner').addClass('hidden');
			$('#search-submit').attr('disabled', false)
			$(window).scrollTop($('.results').offset().top)
		}).fail(function(){
			alert('Something went wrong with the search. Please refresh and try again.')
		});
	});



});