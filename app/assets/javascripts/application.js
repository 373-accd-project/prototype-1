//= require jquery3
//= require rails-ujs
//= require popper
//= require bootstrap-sprockets

// $(function () {
//   $('.alloptions').hide();
//   $('#dataseries_select').change(function () {
//       $('.alloptions').hide();
//       $('#' +$(this).val()).show();
//   });
// });

// // Treeview Initialization
// $(document).ready(function() {
//     $('.treeview').mdbTreeview();
//     console.log("hello");
//   });



function checkboxNest(){
    var toggler = document.getElementsByClassName("caret");
    var i;
    console.log("hello");
    
    for (i = 0; i < toggler.length; i++) {
      toggler[i].addEventListener("click", function() {
        this.parentElement.querySelector(".nested").classList.toggle("active");
        this.classList.toggle("caret-down");
      });
    }
}
