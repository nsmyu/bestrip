function changeNavLinkColor() {
  const path = location.pathname;
  const links = document.querySelectorAll(".sidenav-link");

  if (links) {
    links.forEach((link) => {
      if (link.pathname == path) {
        link.classList.add("current-page");
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', changeNavLinkColor);
document.addEventListener('turbo:load', changeNavLinkColor);
