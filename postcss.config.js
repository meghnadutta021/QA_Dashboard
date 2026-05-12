/**
 * postcss.config.js — PostCSS Configuration
 * ==========================================
 * WHAT IS POSTCSS?
 * ----------------
 * PostCSS is a tool that transforms CSS through a pipeline of plugins.
 * Think of it as a series of filters that your CSS passes through:
 *
 *   input.css  →  [tailwindcss]  →  [autoprefixer]  →  output.css
 *
 * The Tailwind CLI uses PostCSS internally, so this file is read automatically
 * when you run `npm run build:css` or `npm run watch:css`.
 *
 * PLUGINS:
 *   tailwindcss  — generates all the utility classes found in your templates
 *   autoprefixer — adds vendor prefixes like -webkit- for older browser support
 *                  (e.g. `display: flex` becomes `display: -webkit-flex` too)
 */
module.exports = {
  plugins: {
    tailwindcss:  {},
    autoprefixer: {},
  },
};
