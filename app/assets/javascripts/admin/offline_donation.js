function offlineDonationForm() {
  var paymentMethodSelect = $("select#donation_payment_method");
  paymentMethodFields = $(".offline-field");
  
  function showPaymentMethodSpecificFields(clearValues) {
    paymentMethodFields.hide();
    if(clearValues) {
      paymentMethodFields.find("input").val("");
    }
    $("." + paymentMethodSelect.val()).show();
  }
  paymentMethodSelect.change(function() { showPaymentMethodSpecificFields(true); });
  showPaymentMethodSpecificFields(false);
}

(function($) {
  $.fn.umbrellaUserCheckbox = function (options) {
    $(this).click(function(e){
        var checked = $(e.target).attr('checked');
        if (checked) {
          $(options.userIdInputSelector).attr('readonly', 'readonly');
          $(options.userIdInputSelector).val(options.umbrellaUserId);
        } else {
          $(options.userIdInputSelector).removeAttr('readonly');
          $(options.userIdInputSelector).val('');
        }
    });
  };
})(jQuery);
