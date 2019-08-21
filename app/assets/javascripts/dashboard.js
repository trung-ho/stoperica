// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

document.addEventListener('turbolinks:load', function () {
  document.getElementById('faq1').addEventListener('click', function () {
    var info = document.getElementById('info');
    var expandMore = document.getElementById('expand-more');
    var expandLess = document.getElementById('expand-less');
    
    if (info.style.display != 'none') {
      info.style.display = 'none';
      expandLess.style.display = 'none';
      expandMore.style.display = 'block';
    }
    else {
      info.style.display = 'block';
      expandLess.style.display = 'block';
      expandMore.style.display = 'none';
    }
  });
});
