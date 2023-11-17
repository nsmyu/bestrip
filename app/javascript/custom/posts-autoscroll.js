document.addEventListener('turbo:load', () => {
  const pageHeader = document.querySelector(".page-header");

  if (pageHeader && location.pathname == "/posts/search") {
    window.scrollTo(0, 287);
  }
});
