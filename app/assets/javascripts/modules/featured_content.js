var Purpose = Purpose || {};
Purpose.FeaturedContent = Purpose.FeaturedContent || {};

Purpose.FeaturedContent.init = function (view) {
  view.tabsContainer().tabs();

  var addNewModuleContentToPage = function (e, data, status, xhr) {
    var successCallback =  function (target, response) {
      var popupContainer = $('#image-upload-container');
      popupContainer.dialog("close");
      target.val($(response).attr('src'));
    }
    $(data).each(function () {
      var languageContentModule = $(this),
          language = languageContentModule.attr('data-lang'),
          targetElement = view.modulesContainer(language);

      targetElement.append(languageContentModule);
      Purpose.FeaturedContent.setUpModuleActions(languageContentModule);
      Purpose.initImageUploaderOn($(this), successCallback);
    });
  }

  view.allModules().each(function (index, element) {
    Purpose.FeaturedContent.setUpModuleActions(element);
  });

  view.allAddModuleButtons().each(function (index, element) {
    $(element).bind("ajax:success", addNewModuleContentToPage);
  });

  view.allAddModuleWithDataButtons().each(function (index, element) {
    $(element).bind("click", function () {
      $("#jstree-container").jstreeContainer({
        jsonData:campaignTreeJson,
        position:$(element),
        successCallback:function (data) {
          addNewModuleContentToPage(undefined, data);
        }
      });
      return false;
    });
  });

  function highlightContainer() {
    view.rootContainer().addClass("droppable");
  }

  function updateFeaturedContentPosition(event, ui) {
    var updateForm = $("form#sort_featured_content_modules");

    var moduleId = ui.item.attr('data-id');
    var moduleLanguage = ui.item.attr("data-lang"),
        newPosition = $.makeArray(view.modulesPerLanguage(moduleLanguage)).indexOf(ui.item[0]);

    updateForm.find('[name="featured_content_module[id]"]').val(moduleId);
    updateForm.find('[name="featured_content_module[new_position]"]').val(newPosition);
    updateForm.submit();

    view.rootContainer().removeClass("droppable");
  }

  view.allModuleContainers().sortable({
    items:".content_module",
    connectWith:".modules_container",
    handle:".module_header",
    scroll:true,
    start:highlightContainer,
    stop:updateFeaturedContentPosition
  });
};

Purpose.FeaturedContent.createView = function (rootElement) {
  var root = $(rootElement),
      self = {};

  self.rootContainer = function () {
    return root.find(".container");
  };

  self.allModules = function () {
    return root.find('.content_module');
  };

  self.modulesPerLanguage = function (languageCode) {
    return self.languageTab(languageCode).find(".content_module");
  };

  self.allModuleContainers = function () {
    return root.find(".modules_container");
  };

  self.tabsContainer = function () {
    return root.find('#language_tabs');
  };

  self.languageTab = function (languageCode) {
    return root.find('#content-' + languageCode);
  };

  self.modulesContainer = function (languageCode) {
    return self.languageTab(languageCode).find('.modules_container');
  };

  self.allAddModuleButtons = function () {
    return self.tabsContainer().find(".add_module_buttons .add-module-link");
  };

  self.allAddModuleWithDataButtons = function () {
    return self.tabsContainer().find(".add_module_buttons .add-module-link-with-content");
  };

  return self;
};

Purpose.FeaturedContent.setUpModuleActions = function (rootElement) {
  var module = $(rootElement);

  var removeModuleFromDom = function () {
    module.remove();
  };

  var hiddenFields = function () {
    return module.find(".hidden_fields");
  };

  var isCollapsed = function () {
    return !hiddenFields().is(":visible");
  };

  var collapse = function (expandLink) {
    expandLink.removeClass("ui-icon-triangle-1-s");
    expandLink.addClass("ui-icon-triangle-1-e");
    hiddenFields().slideUp();
  };

  var expand = function (expandLink) {
    expandLink.addClass("ui-icon-triangle-1-s");
    expandLink.removeClass("ui-icon-triangle-1-e");
    hiddenFields().slideDown();
  };

  var expandLink = module.find(".expand_collapse_module_fields");
  expandLink.click(function () {
    if (isCollapsed()) {
      expand(expandLink);
    } else {
      collapse(expandLink);
    }
  });

  var removeLink = module.find(".remove_module");
  removeLink.bind("ajax:success", removeModuleFromDom);
};