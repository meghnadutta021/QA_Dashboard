/**
 * tailwind.config.js — Tailwind CSS Configuration
 * =================================================
 * WHAT IS THIS FILE?
 * ------------------
 * Tailwind works by scanning your HTML/template files for class names and
 * generating CSS only for the classes it actually finds. This file tells
 * Tailwind WHERE to look (content), WHAT colours/fonts to add (theme), and
 * WHICH plugins to use.
 *
 * Without this file, Tailwind doesn't know which files to scan and would
 * generate no output CSS at all.
 *
 * @type {import('tailwindcss').Config}
 */
module.exports = {

  // ─── CONTENT ────────────────────────────────────────────────────────────────
  // List every file that contains Tailwind class names.
  // Tailwind reads these files, finds class names like bg-green-100 or px-3,
  // and includes ONLY those classes in the final CSS file.
  // This is why the output is tiny (a few KB) instead of the full ~3 MB library.
  content: [
    './src/main/resources/templates/**/*.ftlh',
  ],

  // ─── THEME ──────────────────────────────────────────────────────────────────
  // `extend` adds your custom values ON TOP of Tailwind's built-in defaults.
  // If you used `theme: {}` without `extend`, you would replace the defaults.
  theme: {
    extend: {

      // Custom accent colour used for nav highlights, buttons, and focus rings.
      // Usage in templates: bg-accent, hover:bg-accent-hover, text-accent, etc.
      colors: {
        accent: {
          DEFAULT: '#4f46e5', // indigo-600
          hover:   '#4338ca', // indigo-700
        },

        // Semantic colour tokens for QA status badges.
        // These mirror the Tailwind built-in colours but give them meaningful
        // QA-specific names so you can restyle all badges in one place.
        //
        // Usage example in a template:
        //   <span class="bg-status-pass-bg text-status-pass-text">PASS</span>
        status: {
          pass: {
            bg:   '#dcfce7', // green-100
            text: '#166534', // green-800
            ring: '#16a34a', // green-600
          },
          fail: {
            bg:   '#fee2e2', // red-100
            text: '#991b1b', // red-800
            ring: '#dc2626', // red-600
          },
          skip: {
            bg:   '#fef9c3', // yellow-100
            text: '#854d0e', // yellow-800
            ring: '#ca8a04', // yellow-600
          },
          blocked: {
            bg:   '#ffedd5', // orange-100
            text: '#9a3412', // orange-800
            ring: '#ea580c', // orange-600
          },
        },
      },

      // Custom font stack — uses Inter if it is loaded; falls back gracefully
      // to the operating system's default sans-serif font otherwise.
      // To actually load Inter, add a Google Fonts <link> in base.ftlh.
      fontFamily: {
        sans: ['Inter', 'ui-sans-serif', 'system-ui', '-apple-system', 'sans-serif'],
      },

    },
  },

  // ─── PLUGINS ────────────────────────────────────────────────────────────────
  // Add Tailwind official plugins here if needed in the future.
  // Example: require('@tailwindcss/forms') for styled form inputs.
  plugins: [],

};
