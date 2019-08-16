// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

document.addEventListener('turbolinks:load', function () {
  document.getElementById('add-info-toggler').addEventListener('click', function () {
    var additionalInformation = document.getElementById('additional-information');
    var expandMore = document.getElementById('expand-more');
    var expandLess = document.getElementById('expand-less');
    
    if (additionalInformation.style.display != 'none') {
      additionalInformation.style.display = 'none';
      expandLess.style.display = 'none';
      expandMore.style.display = 'block';
    }
    else {
      additionalInformation.style.display = 'block';
      expandLess.style.display = 'block';
      expandMore.style.display = 'none';
    }
  })
});
