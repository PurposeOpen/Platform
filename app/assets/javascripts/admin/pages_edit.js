$.page("#action_pages_edit", "#action_pages_update", "#content_pages_new", "#content_pages_edit", "#emails_new", "#emails_create", "#emails_update", "#emails_edit", "#emails_clone", function(page) {
  Purpose.ContentModules.init(Purpose.ContentModules.createView(page));
  Purpose.ActionPages.setUpWarnOnLeavingWithChanges();
  Purpose.Preview.setupPreviewAction();
  Purpose.Preview.disableSaveAndPreviewDuringAjax(page);
  Purpose.ActionPages.getCrowdringCount();
  Purpose.ActionPages.setupImageUploader(page);
});

$.page("#action_pages_edit", "#action_pages_update", function(page) {
  $(".autofire_email_enabled").toggleFields(".autofire_email_details");
  $(".comments_enabled").toggleFields(".comment_details");
  $(".include_action_counter").toggleFields(".action_page_counter");
  Purpose.ActionPages.setUpCharacterCounter();
  Purpose.ActionPages.setUpDisableContentToggle();
});

function hideAskButtonsWhenAskExists() {
  var askCount = $(".module[data-is-ask=true]").length,
      allAskButtons = $(".add-ask-buttons");

  if (askCount === 0) {
    allAskButtons.fadeIn();
  } else {
    allAskButtons.fadeOut();
  }
}

function hideTellAFriendWhenOneExists() {
  var tellAFriendCount = $(".module[class*=tell_a_friend]").length,
      allTafButtons = $(".add-tell-a-friend-button");

  if (tellAFriendCount === 0) {
    allTafButtons.fadeIn();
  } else {
    allTafButtons.fadeOut();
  }
}

function newModuleAddedToPage(modulesList, data) {
  var moduleDom = $(data),
      inlineForms = moduleDom.find("form");

  inlineForms.appendTo("body");

  modulesList.append(moduleDom);
  hideAskButtonsWhenAskExists();
  hideTellAFriendWhenOneExists();
}


function bookmarkableModule(content_module_id, bookmark_url) {
  function showBookmarkForm() {
    bookmarkForm.css("left", bookmarkLink.offset().left - 270 + "px");
    bookmarkForm.css("top", bookmarkLink.offset().top + 7 + "px");
    bookmarkForm.fadeIn('fast');
    return false;
  }

  function hideBookmarkForm() {
    bookmarkForm.fadeOut('fast');
    nameField.val("");
    errorContainer.empty();
    return false;
  }

  function unbookmarked(data, status, xhr) {
    bookmarkLink.show();
    unbookmarkLink.hide();
  }

  function handleResponse(xhr, status) {
    if (status == "error") {
      errorContainer.text(xhr.responseText);
    } else {
      hideBookmarkForm();
      bookmarkLink.hide();
      unbookmarkLink.show();
    }
  }

  function submitBookmarkForm() {
    var data = {
      content_module_id: content_module_id,
      bookmark_name: nameField.val()
    };

    $.ajax({
      url: bookmark_url,
      dataType: 'json',
      data: data,
      complete: handleResponse
    });

    return false;
  }

  var bookmarkLink = $("#bookmark-module-" + content_module_id);
  bookmarkLink.bind("click", showBookmarkForm);

  var unbookmarkLink = $("#unbookmark-module-" + content_module_id);
  unbookmarkLink.bind("ajax:success", unbookmarked);

  var bookmarkForm = $("#bookmark-form-" + content_module_id);
  bookmarkForm.submit(submitBookmarkForm);

  var nameField = bookmarkForm.find("input[name=bookmark_name]");
  var errorContainer = bookmarkForm.find(".error");

  var cancelLink = bookmarkForm.find(".cancel");
  cancelLink.click(hideBookmarkForm);
}


function addFromBookmarks(bookmarksListSelector, modulesListSelector) {
  function moduleAdded(e, data, status, xhr) {
    $.colorbox.close();
    newModuleAddedToPage($(modulesListSelector), data);
  }

  var list = $(bookmarksListSelector);
  list.find("a").bind("ajax:success", moduleAdded);
};
