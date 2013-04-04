(function ($, undefined) {
  $.widget("ui.jstreeContainer", {
    options:{
      "jstree":{
        "json_data":{
          "data":[]
        },
        "themes":{
          "theme":"",
          "dots":true,
          "icons":false
        },
        "ui":{
          "select_limit":1
        },
        "search":{
          "case_insensitive":true,
          "show_only_matches":true
        },
        "plugins":["json_data", "ui", "search", "themes"]
      }
    },

    _init:function () {
      this.options.jstree.json_data.data = this.options.jsonData;
      this._buildHtml();
      this._bindJsTree();
      this.element.show();
      this._positionContainer();
      this._bindClose();
      this._bindSearch();
      this.element.find("#jstree-search").focus();
    },

    _buildHtml:function () {
      this.element.addClass("ui-widget-content jstree-default");
      this.element.html("<div class='search-container ui-widget-header'><label for='jstree-search'>Search : </label><input type='text' name='jstree-search' id='jstree-search'><a class='jstree-close right' href='#'><span class='ui-icon ui-icon-circle-close'></span></a></div><div id='jstree'></div>");
    },

    _bindJsTree:function () {
      var widget = this;
      this.element.find("#jstree").jstree(this.options.jstree)
          .bind("select_node.jstree", this._bindSelectNode()).bind("search.jstree", function (e, data) {
            $.each(data.rslt.nodes, function (index, node) {
              widget._showChildren(data.inst, node);
            });
          });
      ;
    },

    _showChildren:function (jsTree, node) {
      var children = jsTree._get_children(node),
          widget = this;
      if (children.length == 0) return;
      $.each(children, function (index, childNode) {
        $(childNode).show();
        widget._showChildren(jsTree, childNode);
      });
    },

    _bindSelectNode:function () {
      var widget = this;
      return function (e, data) {
        var url = data.rslt.obj.data("url");
        if (url == undefined) {
          widget.element.find("#jstree").jstree("toggle_node", $(data.rslt.obj));
        } else {
          $.ajax({
            url:url,
            type:"POST",
            success:function (data) {
              widget.options.successCallback(data);
              widget.element.hide();
            }
          });
        }
      }
    },

    _positionContainer:function () {
      this.element.position({my:"top", at:"bottom", of:this.options.position});
    },

    _bindClose:function () {
      var widget = this;
      this.element.find(".jstree-close").click(function () {
        widget.element.hide();
        return false;
      });
    },

    _bindSearch:function () {
      var lazySearch = _.debounce(this._search(), 300);
      this.element.find("#jstree-search").keyup(lazySearch);
    },

    _search:function () {
      var widget = this;
      return function () {
        var value = widget.element.find("#jstree-search").val();
        if ($.isEmptyObject(value)) {
          widget.element.find("#jstree").jstree("clear_search");
        } else {
          widget.element.find("#jstree").jstree("search", value);
        }
      }
    }

  });
})(jQuery);