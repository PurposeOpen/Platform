function expandingContent(titleSelector, contentSelector) {
  function titleClicked() {
    content.toggle('blind', 'fast');
    title.toggleClass('expanded');
  }

  var content = $(contentSelector);
  var title = $(titleSelector);
  title.click(titleClicked);
  
  if (anchorString == title.text()) {
    title.toggleClass('expanded');
  } else {
    content.hide(); 
  }
}