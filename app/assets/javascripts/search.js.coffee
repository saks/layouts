jQuery(document).ready ->

  performSearch = ->
    params = jQuery.param search_term: jQuery('#search_term').val()
    document.location = "/items?#{params}"

  jQuery('.search .add-on').click performSearch

  jQuery('.search').keydown (event) -> if event.keyCode is 13 then performSearch()


