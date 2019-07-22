// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

document.addEventListener('turbolinks:load', function () {
  document.getElementById('is_biker_select').addEventListener('change', function () {
    var uclIdField = document.getElementById('uci_id_field');
    if (this.value === "0") {
      uclIdField.style.display = 'none';
    }
    else {
      uclIdField.style.display = 'block';
    }
  })
});
