ns4 = document.layers
ie4 = document.all
nn6 = document.getElementById && !document.all
function hideObject(id) {
   if (ns4) {
      document.id.visibility = "hide";
   }   else if (ie4) {
      document.all[id].style.visibility = "hidden";
   }   else if (nn6) {
      document.getElementById(id).style.visibility = "hidden";
 }
}
function showObject(id) {
   if (ns4) {
      document.id.visibility = "show";
   }   else if (ie4) {
      document.all[id].style.visibility = "visible";
   }   else if (nn6) {
      document.getElementById(id).style.visibility = "visible";
   }
}
