$(document).ready ->

  inputs = jQuery 'input.autocomplete_with_tags'

  syncWithInput = ->
    inputs.each (index, input) ->
      input  = jQuery input
      tags   = input.tokenInput 'get'

      input.attr 'value', (tag.id for tag in tags).join ','


  for input in inputs
    input = jQuery input
    input.tokenInput '/tags',
      crossDomain:       false,
      preventDuplicates: true,
      propertyToSearch:  'id',
      theme:             'layouts',
      queryParam:        input.data('queryparam'),
      onAdd:             -> syncWithInput(),
      onRemove:          -> syncWithInput(),


  $('.token-input-input-token-layouts input').
    focus( -> jQuery(this).parents('ul').addClass 'focus').
    blur   -> jQuery(this).parents('ul').removeClass 'focus'
