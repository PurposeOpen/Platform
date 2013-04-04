$(function(){
  if($("#quick_go_query").length == 0) return;
  var path = $("#quick_go_query").attr('data-path');
  $("#quick_go_query").autocomplete({
    source: path,
    select: function(event, ui){
      window.location = ui.item.path;
      return false;
    }
  }).data("autocomplete")._renderItem = function( ul, item ) {
    return $( "<li>" )
    .data("item.autocomplete", item)
    .append( "<a href='"+item.path +"' class='suggestion-link'><div class='suggestion'>" + item.name + "</div><div class='suggesion-type'>" + item.type + "</div></a>" )
    .appendTo( ul );
  };
});
