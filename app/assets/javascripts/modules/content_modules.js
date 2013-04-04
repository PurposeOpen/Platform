 var Purpose = Purpose || {};
Purpose.ContentModules = Purpose.ContentModules || {};

Purpose.ContentModules.init = function(view) {
  view.tabsContainer().tabs();
  
  var addNewModuleContentToPage = function (e, data, status, xhr) {
    var layoutType = view.buttonLayoutTypeFor(this);
    
    $(data).each(function() {
      var languageContentModule = $(this),
          language = languageContentModule.attr('data-lang'),
          targetElement = view.modulesContainer(language, layoutType);

      targetElement.append(languageContentModule);

      Purpose.ContentModules.createModule(languageContentModule);
    });
  };

  view.allModules().each(function(index, element) {
    Purpose.ContentModules.createModule(element);
  });

  view.allAddModuleButtons().each(function(index, element) {
    $(element).bind("ajax:success", addNewModuleContentToPage);
  });

  view.allModuleContainers().each(function(index, element) {
    Purpose.ContentModules.createContainer(element);
  });
};

Purpose.ContentModules.createView = function(rootElement) {
  var root = $(rootElement),
      self = {};

  self.allModules = function() {
    return root.find('.content_module');
  };

  self.allModuleContainers = function() {
    return root.find(".modules_container");
  };

  self.tabsContainer = function() {
    return root.find('#language_tabs');
  };

  self.languageTab = function(languageCode) {
    return root.find('#page-' + languageCode);
  };

  self.layoutTypeContainer = function(languageCode, layoutType) {
    return self.languageTab(languageCode).find('[data-layout-type="' + layoutType + '"]');
  };

  self.modulesContainer = function(languageCode, layoutType) {
    return self.layoutTypeContainer(languageCode, layoutType).find('.modules_container');
  };

  self.allAddModuleButtons = function() {
    return self.tabsContainer().find(".add_module_buttons a");
  };

  self.buttonLayoutTypeFor = function(button) {
    return $(button).parents('[data-layout-type]').attr('data-layout-type');
  };

  return self;
};

Purpose.ContentModules.createContainer = function(rootElement) {
  var root = $(rootElement);

  var destinationContainerIsValid = function(source, destination) {
    var allowedContainers = $(source).attr('data-valid-containers').split(' '),
        destinationContainer = $(destination).attr('data-layout-type');

    return allowedContainers.indexOf(destinationContainer) >= 0;
  };

  var startModuleSorting = function(event, ui) {
    removeTinyMceForDraggedModule(ui);
    indicateDroppableContainers(ui);
  };

  var indicateDroppableContainers = function(ui) {
    var allowedContainers = $(ui.item).attr('data-valid-containers').split(' ');

    $(allowedContainers).each(function() {
      $(".container[data-layout-type=" + this + "]").addClass("droppable");
    });
  };

  var preventOverOnInvalidContainers = function(event, ui) {
    var destination = $(ui.placeholder).closest(".container");

    if (!destinationContainerIsValid(ui.item, destination)) {
      $(ui.placeholder).addClass("ui-sortable-placeholder-invalid");
    }    
  };

  var cancelReceiveOnInvalidContainers = function(event, ui) {
    var destination = $(ui.item).closest(".container");

    if (!destinationContainerIsValid(ui.item, destination)) {
      $(ui.sender).sortable('cancel');
    }
  };

  var saveNewModuleContainerAndPosition = function(event, ui) {
    var destination = ui.item.closest(".container"),
        newContainer = destination.attr('data-layout-type'),
        allModules = destination.find(".content_module"),
        newPosition = $.makeArray(allModules).indexOf(ui.item[0]),
        moduleId = ui.item.attr('data-id'),
        updateForm = $("form#sort_content_modules");

    $(".container").removeClass("droppable");

    addTinyMceForDraggedModule(ui);
    
    updateForm.find('[name="content_module[content_module_id]"]').val(moduleId);
    updateForm.find('[name="content_module[new_container]"]').val(newContainer);
    updateForm.find('[name="content_module[new_position]"]').val(newPosition);
    updateForm.submit();
  };

  var removeTinyMceForDraggedModule = function(ui) {
    var draggedModulesTextEditorId = $('textarea.html-editor', ui.item).attr('id');
    tinymce.execCommand('mceRemoveControl', true, draggedModulesTextEditorId);
  };

  var addTinyMceForDraggedModule = function(ui) {
    var draggedModulesTextEditorId = $('textarea.html-editor', ui.item).attr('id');
    tinymce.execCommand('mceAddControl', true, draggedModulesTextEditorId);
  }

  root.sortable({
    items: ".content_module",
    connectWith: ".modules_container",
    handle: ".module_header",
    scroll: true,
    start: startModuleSorting,
    over: preventOverOnInvalidContainers,
    receive: cancelReceiveOnInvalidContainers,
    stop: saveNewModuleContainerAndPosition
  });
};

Purpose.ContentModules.createModule = function(rootElement) {
  var module = $(rootElement),
      moduleActions = module.find(".module_actions"),
      removeLink = moduleActions.find(".remove_module"),
      disabledActions = moduleActions.find(".ui-icon.disabled");

  var removeModuleFromDom = function() {
    hideAskButtonsWhenAskExists();
    hideTellAFriendWhenOneExists();
    module.remove();
  }

  disabledActions.click(function(evt) { evt.preventDefault(); evt.stopPropagation(); });
  removeLink.bind("ajax:success", removeModuleFromDom);
};