$(document).ready(function () {
    function updatePreviewWindow(anchorTag) {
        var url = anchorTag.attr("href");
        $(".action_sequence_breadcrumb a.current:visible").removeClass("current");
        anchorTag.addClass("current");
        $("#preview_window").html("<iframe src='" + url + "' width='100%' height='1000px'/>");
    }

    $("#homepage-preview-languages-tab").tabs({
        show: function(event, ui){
            updatePreviewWindow($(ui.panel).find("li:first-child a"));
        }
    });

    $("#action-pages-languages-tab").tabs({
        show: function(event, ui){
            updatePreviewWindow($(ui.panel).find(".action_sequence_breadcrumb li a.current:visible"));
        }
    });

    $(".action_sequence_breadcrumb a, .homepage_preview a").click(function (event) {
        event.preventDefault();
        updatePreviewWindow($(this));
        return false;
    });
});
