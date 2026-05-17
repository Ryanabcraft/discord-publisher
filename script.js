const toast = document.querySelector(".toast");

document.querySelectorAll("[data-copy]").forEach((button) => {
  button.addEventListener("click", async () => {
    const target = document.getElementById(button.dataset.copy);
    const text = target?.innerText.trim();
    if (!text) return;

    await navigator.clipboard.writeText(text);
    toast.classList.add("show");
    button.textContent = "Copiado";

    window.setTimeout(() => {
      toast.classList.remove("show");
      button.textContent = "Copiar";
    }, 1400);
  });
});
