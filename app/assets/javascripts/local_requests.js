function addItemRadio(container, item) {
    var pid = item['item_data']['pid'];
    var div = document.createElement('div')
    div.class = 'radio'
    // TODO: add delivery options as data attribute?
    var input = document.createElement('input');
    input.name = "item-select-" + pid;
    input.type = 'radio';
    input.value = pid;
    var label = document.createElement('label');
    label.htmlFor = "item-select-" + pid;
    label.appendChild(input);
    var radio_label_text =
        document.createTextNode(
            item['bib_data']['title'] + " - " +
            item['item_data']['description']
        )
    label.appendChild(radio_label_text);
    div.appendChild(label);
    container.append(div);
}

function holdingUrl(mms_id, holding_id) {
    return "/alma/" + mms_id + "/holding/" + holding_id + "/items"
}

$(document).ready(function() {
    $('.item-select-button').click(function() {
        var $elem = $(this);
        var mmsId = $elem.data('mms-id');
        var holdingId = $elem.data('holding-id');
        var $radioContainer = $elem.closest('div.panel')
            .find('div.item-select-container');
        if($radioContainer.html() === "") {
            $.getJSON(holdingUrl(mmsId, holdingId))
                .fail(function() { alert("Oh no!") })
                .done(function(data) {
                    // todo only if destination is empty!
                    $.each(data, function(i, item) {
                        addItemRadio($radioContainer, item['item'])
                    });
                });
        }

    });
});