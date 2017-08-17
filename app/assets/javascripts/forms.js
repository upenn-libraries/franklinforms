function submit_fixit() {
  return form_validate(['email', 'title']);
}

function submit_ill() {
  return form_validate(['email', 'booktitle', 'chaptitle', 'pages', 'journal', 'article', 'rftdate', 'year', 'author']);
}

function submit_booksbymail() {
  return form_validate(['email', 'title', 'author']);
}

function submit_help() {
  return form_validate(['name', 'email', 'details']);
}

function form_validate(required) {
  var alertmsg = "The following field(s) are required:\n\n";
  var errors = false;

  for(i = 0; i < required.length; i++) {
    var id = required[i];
    var field = $('#' + id);

    // skip field if not found on form
    if(field.length == 0) {
      continue;
    }

    var label = $('label[for=' + id + ']');

    if(field.val().trim().length == 0) {
      alertmsg += "- " + label.text() + "\n";
      field.addClass('field_with_errors');
      label.addClass('field_with_errors');
      errors = true;
    }
  }

  if(errors) {
    alert(alertmsg);
  }

  return !errors;
}
