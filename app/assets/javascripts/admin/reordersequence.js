$(document).ready(function() {
  $('.unlock-sorting').click(function() {
    var link = $(this);
    link.fadeOut();

    var url = link.attr("data-unlock-url"), 
        listSelector = "#" + link.attr("data-unlock");

    reorderSequence(url, listSelector + " ul", listSelector);
  });
});

function reorderSequence(reorderUrl, listSelector, toFlash) {
  var list = $(listSelector);

  function sequencesReordered(xhr) {
    $(toFlash).effect('highlight');
  }
  
  function reorderSequences() {
    $.ajax({
      url: reorderUrl,
      type: 'put',
      data: list.sortable('serialize'),
      complete: sequencesReordered
    });
  }

  list.find('.handle').removeClass("disabled").fadeTo("fast", 1.0);

  list.sortable({
    axis: 'y',
    dropOnEmpty: false,
    handle: '.handle',
    cursor: 'crosshair',
    items: 'li',
    opacity: 0.4,
    scroll: true,
    update: reorderSequences
  }); 
}