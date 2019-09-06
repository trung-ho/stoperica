// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

document.addEventListener('turbolinks:load', function () {
  let elements = document.getElementsByClassName("text-hidden");

  for (i = 0; i < elements.length; i++) {
    elements[i].addEventListener('click', function () {

      var info = this.nextElementSibling;
      var expandMore = this.querySelector('.expand-more');
      var expandLess = this.querySelector('.expand-less');

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
  }
});
