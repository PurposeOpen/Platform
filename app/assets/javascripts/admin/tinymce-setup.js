$(function() {
  var defaultOptions = {
    plugins: "autolink,contextmenu,paste,fullscreen,inlinepopups,table,preview,style, purposeImageManagerPlugin",
    theme_advanced_statusbar_location: "none",
    theme_advanced_toolbar_location: "top",
    theme_advanced_font_sizes: "8px=8px,9px=9px,10px=10px,11px=11px,12px=12px,13px=13px,14px=14px,15px=15px,16px=16px,17px=17px,18px=18px,19px=19px,20px=20px",
    convert_urls: false,
    forced_root_block: false,
    dialog_type: "modal",
    style_formats: [
        {title: 'Paragraph', block: 'p'},
        {title: 'Heading 1', block: 'h1'},
        {title: 'Heading 2', block: 'h2'},
        {title: 'Heading 3', block: 'h3'},
        {title: 'Heading 4', block: 'h4'}
    ],
    schema: "html5",
    width: "100%",
    setup: function(editor) {
      editor.onChange.add(function() { Purpose.setConfirmUnload(true); });
      editor.onSubmit.add(function() { Purpose.setConfirmUnload(false); });
    }
  };
  
  var fullEditor = $.extend({}, defaultOptions, {
    theme_advanced_buttons1: "bold,italic,underline,|,justifyleft,justifycenter,justifyright,|,styleselect,fontselect,fontsizeselect,styleprops,removeformat,|,preview,code,fullscreen",
    theme_advanced_buttons2: "bullist,numlist,hr,|,outdent,indent,|,undo,redo,|,link,unlink,image,|,tablecontrols,forecolor,backcolor,purposeImageManagerPlugin",
    verify_css_classes: true,
    schema: "html4"
  });

  var regularEditor = $.extend({}, defaultOptions, {
    theme_advanced_buttons1: "bold,italic,underline,|,justifyleft,justifycenter,justifyright,|,styleselect,|,hr",
    theme_advanced_buttons2: "bullist,numlist,|,outdent,indent,|,undo,redo,|,link,unlink,image,|,code,fullscreen, purposeImageManagerPlugin"
  });

  var compactEditor = $.extend({}, defaultOptions, {
    theme_advanced_buttons1: "bold,italic,underline,|,undo,redo,|,link,unlink,|,code"
  });

  var minimalEditor = $.extend({}, defaultOptions, {
    theme_advanced_buttons1: "bullist,|,undo,redo,|,link,unlink,|,code"
  });

  $('textarea.html-full-editor').livequery(function() { $(this).tinymce($.extend(fullEditor, this.dataset));});

  $('div[data-script-directionality="left-to-right"] textarea.html-editor').livequery(function() {
    $(this).tinymce($.extend({}, regularEditor, this.dataset));
  });
  $('div[data-script-directionality="right-to-left"] textarea.html-editor').livequery(function() {
    $(this).tinymce($.extend({}, regularEditor, {skin: 'right_to_left'}, this.dataset));
  });

  $('[data-script-directionality="left-to-right"] textarea.html-compact-editor').livequery(function() { $(this).tinymce(compactEditor) });
  $('[data-script-directionality="right-to-left"] textarea.html-compact-editor').livequery(function() {
    $(this).tinymce($.extend({}, compactEditor, {skin: 'right_to_left'}));
  });

  $('[data-script-directionality="left-to-right"] textarea.html-minimal-editor').livequery(function() {
    $(this).tinymce(minimalEditor);
  });
  $('[data-script-directionality="right-to-left"] textarea.html-minimal-editor').livequery(function() {
    $(this).tinymce($.extend({}, minimalEditor, {skin: 'right_to_left'}));
  });
});
