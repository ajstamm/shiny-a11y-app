## Accessible penguins

Designed by [Abigail Stamm](https://github.com/ajstamm), Fall 2024

This app illustrates several accessibility features available in Shiny dashboards. It is not entirely cohesive as an app since each tab is designed to illustrate specific features.

To run the app yourself, clone the repository, open the file "WCAG_penguins.R" in RStudio, and click "Run App".

## WCAG guidelines illustrated in the app

For specific details on each item, see the 
[WCAG guidelines at W3.org](https://www.w3.org/WAI/WCAG22/quickref/).

### General navigation

* 1.3.4 Orientation (AA)
    - graph wide or squished
* 1.4.10 Reflow (AA)
    - resize window
* 3.2.3 Consistent Navigation (AA)
    - same look, feel, and organization
* 2.4.2 Page Titled (A) 
    - tab title

### Sidebar

* 3.3.2 Labels or Instructions (A)
    - Tell the user what they can do and expect
* 1.3.5 Identify Input Purpose (AA) 
    - instructions
    - aria text
* 3.2.2 Content Change On Input (A) 
    - immediate, noted in instructions
* 3.2.4 Consistent Identification (AA)
    - all tabs work the same way, all dropdowns, all buttons
    - aria text matches written text

### About data tab

* 1.1.1 Non-text Content (A) 
    - aria text or alt text for images
    - [ANDI at the Social Security Administration](https://www.ssa.gov/accessibility/andi/help/install.html)

### Individual data tab

* 2.1.1 Keyboard Navigation (A) 
    - tab, shift tab, arrows
    - [ANDI at the Social Security Administration](https://www.ssa.gov/accessibility/andi/help/install.html)
* 2.4.7 Keyboard Focus Visible (AA)
    - note black outline
* 2.4.3 Focus Order (A) 
    - note top to bottom, left to right

### Plots tabs

**bar:**

* 1.4.1 Non-text Use of Color (A) 
    - colors work for greyscale and color blind
    - introduce colorbrewer
* 1.4.11 Non-Text Color Contrast (AA)
    - adelie too light - blends into background - add border
    - border and darkest color blend - fine, not informative
    - textures - note pattern size
* 1.4.13 Content on Hover or Focus (AA)
    - tables (optional download)

**line:**

* 1.4.1 Non-text Use of Color (A) 
    - lines only maybe hard to understand - add markers (find hovers)
* 1.4.11 Non-Text Color Contrast (AA)
    - Adelie still hard to see - dark palette (greyscale, colorblind okay)
    - line patterns, then marker patterns
* 1.4.13 Content on Hover or Focus (AA)
    - tables (optional download)

### Text formatting tab

* 1.4.4 Resize Text (AA)
    - text box change to show versatility
    - zoom for whole browser
* 1.4.12 Text Spacing (AA)
* 1.4.3 Text Color Contrast (Minimum) (AA) 
    - ratio 3:1 acceptable for above 18pt text
    - ratio 4.5:1 for text below 18pt
    - orange vs purple, for example

### WCAG fails

* 3.3.1 Error Identification (A)
  - Bar chart tab: filter on Gentoo and Dream
    - Failure: textured bar chart displays uninformative error
    - Success: plain bar chart displays instructions
* 1.3.3 Sensory Characteristics (A)
  - Bar chart tab: plotly icons
    - Failure: no non-hover text equivalent and uninformative ARIA text
    - Possible (not ideal) solution: deactivate icons




