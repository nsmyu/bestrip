function changeScheduleIconColor() {
const icons = document.getElementsByClassName("schedule-icon");
const rest = ["restaurant", "local_cafe", "hotel"];
const sightseeing = ["castle", "attractions", "shopping_cart", "landscape", "local_activity"];
const transport = ["train", "directions_car", "directions_bus", "flight", "directions_walk", "directions_bike"];

for (const icon of icons) {
  if (rest.includes(icon.textContent)) {
    icon.classList.add("bg-accent");
  } else if (sightseeing.includes(icon.textContent)) {
    icon.classList.add("bg-warning");
  } else {
    icon.classList.add("bg-info");
  }
}
}

document.addEventListener('DOMContentLoaded', changeScheduleIconColor);
document.addEventListener('turbo:frame-load', changeScheduleIconColor);
