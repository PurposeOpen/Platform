$(document).ready(function () {
  if ($.ech && $.ech.multiselectcheckboxfilter) {
    $.ech.multiselectcheckboxfilter.prototype._handler = function( e ){
      var rEscape = /[\-\[\]{}()*+?.,\\\^$|#\s]/g;
      var term = $.trim( this.input[0].value.toLowerCase() ),

      // speed up lookups
          rows = this.rows, inputs = this.inputs, cache = this.cache;

      if( !term ){
        rows.show();
      } else {
        rows.hide();

        var regex = new RegExp(term.replace(rEscape, "\\$&"), 'gi');

        this._trigger( "filter", e, $.map(cache, function(v, i){
          if( v.search(regex) !== -1 ){
            rows.eq(i).show();
            return inputs.get(i);
          }

          return null;
        }));
      }

      var iteratingOptGroup = undefined;
      var isRootVisible = undefined;
      var hideElement = function(iteratingOptGroup, isRootVisible) {
        if(iteratingOptGroup != undefined && isRootVisible == false){
          iteratingOptGroup['hide']();
        }
      }
      // show/hide optgroups
      this.instance.menu.find(".ui-multiselectcheckbox-optgroup-label").each(function(){
        var $this = $(this);
        if($this.hasClass("root-opt-group")){
          hideElement(iteratingOptGroup, isRootVisible);
          iteratingOptGroup = $this;
          isRootVisible = false;
          return;
        }
        var isVisible = $this.nextUntil('.ui-multiselectcheckbox-optgroup-label').filter(function(){
          return $.css(this, "display") !== 'none';
        }).length;
        if(isVisible){
          isRootVisible = true
          iteratingOptGroup['show']();
        }
        $this[ isVisible ? 'show' : 'hide' ]();
      });
      hideElement(iteratingOptGroup, isRootVisible);
    }
  }});