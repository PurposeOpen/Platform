$(document).ready(function () {
    $(".truncate").live("click", function () {
        var element = $(this), truncateClass = "truncated_version";
        element.toggleClass(truncateClass);
    });
});