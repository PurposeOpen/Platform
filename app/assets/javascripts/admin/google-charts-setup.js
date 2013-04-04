$(function() {

  $('.has-chart').livequery(function() {
    var table = $(this);
    table.attc({
      hideTable: 'true',
      controls: { chartType: false },
      googleOptions: {
        backgroundColor: 'transparent'
      }
    });
  });

});