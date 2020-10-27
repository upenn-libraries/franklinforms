function submit_fixit() {
  return form_validate(['email', 'title']);
}

// no longer used in ILL form
function submit_ill() {
  return form_validate(['email', 'booktitle', 'chaptitle', 'pages', 'journal',
      'article', 'rftdate', 'year', 'author']);
}

// BBM form is no longer used
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

function init_report_error_form() {
  // Hide holding form-group
  $('select[name="[holding]"').parent().parent().hide();
}

function update_title() {
  var report_type = $('input[name="[report_type]"]:checked').val();
  var type_title_heading = $('#type_title');

  switch(report_type) {
    case "fixopac":
      type_title_heading.text("Report cataloging error");
      $('select[name="[holding]"').parent().parent().hide();
      break;
    case "enhanced":
      type_title_heading.text("Request enhanced cataloging");
      $('select[name="[holding]"').parent().parent().hide();
      break;
    case "missing":
      type_title_heading.text("Report item missing");
      $('select[name="[holding]"').parent().parent().show();
      break;
  }
}
