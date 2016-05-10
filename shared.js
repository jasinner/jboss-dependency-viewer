//parsing GET values
function parseSecond(val) {
    var result = "Not passed",
        tmp = [];
    var items = window.location.search.substr(1).split("&");
    for (var index = 0; index < items.length; index++) {
        tmp = items[index].split("=");
        if (tmp[0] === val) result = decodeURIComponent(tmp[1]);
    }
    return result;
}
