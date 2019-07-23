document.addEventListener('turbolinks:load', function () {
  document.getElementById('is_biker_select').addEventListener('change', function () {
    var uclIdField = document.getElementById('uci_id_field');
    if (this.value === "1") {
      uclIdField.style.display = 'block';
    }
    else {
      uclIdField.style.display = 'none';
    }
  })
});
