// Year in footer
document.getElementById('year').textContent = new Date().getFullYear();

// Animated stat counters
const stats = document.querySelectorAll('.stat-num');
const animateCount = (el) => {
  const target = +el.dataset.target;
  const duration = 1400;
  const start = performance.now();
  const step = (now) => {
    const p = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - p, 3);
    el.textContent = Math.round(target * eased);
    if (p < 1) requestAnimationFrame(step);
  };
  requestAnimationFrame(step);
};

const io = new IntersectionObserver((entries) => {
  entries.forEach((e) => {
    if (e.isIntersecting) {
      animateCount(e.target);
      io.unobserve(e.target);
    }
  });
}, { threshold: 0.4 });

stats.forEach((s) => io.observe(s));

// CTA form
const form = document.getElementById('signup');
const note = document.getElementById('cta-note');
if (form) {
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    form.reset();
    note.hidden = false;
  });
}