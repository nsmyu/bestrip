function changeNavLinkColor() {
  const url = location.href;
  const links = document.querySelectorAll(".sidenav-link");

  if (links) {
    links.forEach((link) => {
      if (link.href == url) {
        link.classList.add("current-page");
      }
    });
  };
}

document.addEventListener('DOMContentLoaded', changeNavLinkColor);
document.addEventListener('turbo:load', changeNavLinkColor);
