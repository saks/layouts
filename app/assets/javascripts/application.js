// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery.tokeninput
//= require_tree .


$(document).ready(function () {

  var inputs = $('input.autocomplete_with_tags');

  function syncWithInput() {
    inputs.each(function(index, input) {
      var input = $(input), tags = input.tokenInput('get'), result = [];
      for ( var i = 0; i < tags.length; i++ ) result.push(tags[i].name);

      input.attr('value', result.join(','));
    })
  };

  inputs.each(function() {
    var input = $(this);

    input.tokenInput('/tags', {
      queryParam: input.data('queryparam'),
      crossDomain: false,
      preventDuplicates: true,
      theme: 'layouts',
      onAdd: function() { syncWithInput() },
      onRemove: function() { syncWithInput() }
    });
  });


  $('.token-input-input-token-layouts input').focus(function() {
    $(this).parents('ul').addClass('focus')
  });

  $('.token-input-input-token-layouts input').blur(function() {
    $(this).parents('ul').removeClass('focus')
  });




  // handlers search from layout
  $('.search .add-on').click(function() {
    var query = $.param({search_term: $('#search_term').val(), is_search: 'true'});
    document.location = '/items' + '?' + query;
  });
});

