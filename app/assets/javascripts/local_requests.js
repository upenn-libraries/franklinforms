// Add a radio button input and bootsrapy markup for given
// _item_ inside _container_
function addItemRadio(container, item) {
    var pid = item['pid'];
    var div = document.createElement('div')
    div.className = 'radio'
    // TODO: add delivery options as data attribute?
    var input = document.createElement('input');
    input.name = "item-select";
    input.className = "item-select-radio"
    input.type = 'radio';
    input.value = pid;
    input.setAttribute(
        'data-delivery',
        item['delivery_options'].join(':')
    )
    var label = document.createElement('label');
    // label.htmlFor = "item-select";
    label.appendChild(input);
    var radio_label_text = document.createTextNode(item['label'])
    label.appendChild(radio_label_text);
    div.appendChild(label);
    container.append(div);
}

// calculate URL for grabbing item metadata from local API endpoint
function holdingUrl(mms_id, holding_id) {
    return "/alma/" + mms_id + "/holding/" + holding_id + "/items"
}

$(document).ready(function() {
    // event handler for clicking on accordion button for holding
    $('.item-select-button').click(function() {
        var $elem = $(this);
        var $radioContainer = $elem.closest('div.panel')
            .find('div.item-select-container');
        if($radioContainer.html() === "") {
            var mmsId = $elem.data('mms-id');
            var holdingId = $elem.data('holding-id');
            $.getJSON(holdingUrl(mmsId, holdingId))
                .fail(function() { alert("Oh no!") })
                .done(function(data) {
                    $.each(data, function(i, item) {
                        addItemRadio($radioContainer, item)
                    });
                });
        }
    });

    function deliveryOptionLabel(option) {
        switch (option) {
            case 'scandeliver':
                return 'Request Digital Delivery';
            case 'pickup':
                return 'PickUp@Penn';
            case 'booksbymail':
                return 'Books by Mail';
        }
    }

    // event handler for updating delivery option select when item
    // is chosen
    $(document).on('click', '.item-select-radio', function() {
        var deliverySelect = document.getElementById('local_request_delivery_method');
        // TODO: remove all but the default
        deliverySelect.innerHTML = '';
        var deliveryOptions = this.getAttribute('data-delivery').split(":")
        deliveryOptions.forEach(function(option) {
            var optionText = deliveryOptionLabel(option);
            var optionElement = document.createElement('option');
            optionElement.text = optionText;
            optionElement.value = option;
            deliverySelect.appendChild(optionElement);
        })
    });
});