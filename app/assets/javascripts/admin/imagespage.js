function imagesPage() {

    /* update/show/hide custom size elements based on selection */
    function configureCustomSize(refresh) {
        $("select option:selected").each(function () {
            if (refresh === null) {
                refresh = false;
            }
            var dims = $(this).attr("value").split("x"); // eg "640x480"
            if (dims.length <= 1) {
                if (refresh) {
                    $('#upload-image-form .custom-size').show();
                } else {
                    $('#upload-image-form .custom-size').fadeIn();
                }
            }
            else if (dims.length >= 2) {
                if (refresh) {
                    $('#upload-image-form .custom-size').hide();
                } else {
                    $('#upload-image-form .custom-size').fadeOut();
                }
                var w = dims[0];
                var h = dims[1];
                $('#upload-image-form .height').val(h);
                $('#upload-image-form .width').val(w);
            }
        });
    }

    function configureResize(refresh) {
        if (refresh === null) {
            refresh = false;
        }
        var checked = $('#upload-image-form .image-resize').attr('checked');
        if (checked) {
            $('#upload-image-form .image-dimensions').show();
        }
        else {
            $('#upload-image-form .image-dimensions').hide();
        }
    }

    function attachSelectionHooks() {
        $('#upload-image-form .image-resize').change(function () {
            configureResize(false);
        });
        $("select").change(
            function () {
                configureCustomSize(false);
            }).change();
    }

    function initializePage() {
        var refresh = $('#upload-image-form .error').length > 0;
        configureCustomSize(refresh);
        configureResize(refresh);
    }

    initializePage();
    attachSelectionHooks();
}