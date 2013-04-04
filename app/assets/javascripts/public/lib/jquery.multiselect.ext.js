$(document).ready(function () {
  if ($.ech && $.ech.multiselectcheckbox) {
    $.ech.multiselectcheckbox.prototype.refresh = function (init) {
      var el = this.element,
          o = this.options,
          menu = this.menu,
          checkboxContainer = this.checkboxContainer,
          optgroups = [],
          html = "",
          id = el.attr('id') || multiselectcheckboxID++; // unique ID for the label & option tags

      // build items
      el.find('optgroup,option').each(function (i) {
        if (this.tagName == 'OPTGROUP') {
          if (this.getAttribute('parent-group')) {
            html += '<li class="root-opt-group ui-multiselectcheckbox-optgroup-label">' + this.getAttribute('label') + '</li>';
          }
          return;
        }
        var $this = $(this),
            parent = this.parentNode,
            title = this.innerHTML,
            description = this.title,
            value = this.value,
            inputID = 'ui-multiselectcheckbox-' + (this.id || id + '-option-' + i),
            isDisabled = this.disabled,
            isSelected = this.selected,
            labelClasses = [ 'ui-corner-all' ],
            liClasses = (isDisabled ? 'ui-multiselectcheckbox-disabled ' : ' ') + this.className,
            optLabel;

        // is this an optgroup?
        if (parent.tagName === 'OPTGROUP') {
          optLabel = parent.getAttribute('label');
          optID = parent.getAttribute('id');

          // has this optgroup been added already?
          if ($.inArray(optID, optgroups) === -1) {
            html += '<li class="ui-multiselectcheckbox-optgroup-label ' + parent.className + '"><a href="#">' + optLabel + '</a></li>';
            optgroups.push(optID);
          }
        }

        if (isDisabled) {
          labelClasses.push('ui-state-disabled');
        }

        // browsers automatically select the first option
        // by default with single selects
        if (isSelected && !o.multiple) {
          labelClasses.push('ui-state-active');
        }

        html += '<li class="' + liClasses + '">';

        // create the label
        html += '<label for="' + inputID + '" title="' + description + '" class="' + labelClasses.join(' ') + '">';
        html += '<input id="' + inputID + '" name="multiselectcheckbox_' + id + '" type="' + (o.multiple ? "checkbox" : "radio") + '" value="' + value + '" title="' + title + '"';

        // pre-selected?
        if (isSelected) {
          html += ' checked="checked"';
          html += ' aria-selected="true"';
        }

        // disabled?
        if (isDisabled) {
          html += ' disabled="disabled"';
          html += ' aria-disabled="true"';
        }

        // add the title and close everything off
        html += ' /><span>' + title + '</span></label></li>';
      });

      // insert into the DOM
      checkboxContainer.html(html);

      // cache some moar useful elements
      this.labels = menu.find('label');
      this.inputs = this.labels.children('input');

      // set widths
      this._setButtonWidth();
      this._setMenuWidth();

      // remember default value
      this.button[0].defaultValue = this.update();

      // broadcast refresh event; useful for widgets
      if (!init) {
        this._trigger('refresh');
      }
    }
  }
});


