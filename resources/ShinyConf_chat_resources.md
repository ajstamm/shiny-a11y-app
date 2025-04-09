# ShinyConf 2025 noteworthy chat items

Thanks to our coworker Analise for collecting these for us.

## Links we shared

Code for the presentation:  
github.com/tidy-MN/shiny-a11y-apps
Code to follow along with how to make your dashboard accessible:  
https://github.com/tidy-MN/shiny-a11y-apps/blob/master/walkthrough/app_to_fix.R

## Recommended tools from participants (we have no comment on these)

### For color contrast

* [Colour Contrast Checker](https://colourcontrast.cc/)
* [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)
* [ColorBlindly](https://wearecolorblind.com/resources/colorblindly-colorblindness-simulator/)
    * note: this is a Chrome extension
* [Adobe Color](https://color.adobe.com/)
    * note: this appears not to be free
* [Data Viz Palette](): simulate color deficiency
    * note: I could not find the link for this
* [Coblis](https://www.color-blindness.com/coblis-color-blindness-simulator/)
* [Viz Palette](https://projects.susielu.com/viz-palette)
* [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
* [Coloring for Colorblindness](https://davidmathlogic.com/colorblind/)
* [APCA contrast calculators](https://www.myndex.com/APCA/): more strict than WCAG for dark mode
* [`viridis`](https://sjmgarnier.github.io/viridis/index.html) 
* [`khroma`](https://packages.tesselle.org/khroma/articles/tol.html): includes Paul Tol color schemes
* [Colorbrewer](https://colorbrewer2.org/) for maps
    * note: also [`RColorBrewer`](https://CRAN.R-project.org/package=RColorBrewer)
* [`colorblindr`](https://github.com/clauswilke/colorblindr) 
* [Color Optimizer](https://aboricholololo.shinyapps.io/ColorOptimizer/): created by a friend in Minnesota state government


### For alt text

* For decorative images, use alt=""
* For bootstrap (or bslib), use <span class="visually-hidden">only a screen reader sees this</span>.

### R packages

* [`aftables`](https://github.com/best-practice-and-impact/aftables) for accessible spreadsheets
* [`r-sidebot`](https://github.com/jcheng5/r-sidebot) for app chatbot
* [`shiny-i18n`](https://appsilon.com/rhinoverse/shiny-i18n) to internationalize apps

### Other resources

* WCAG size and spacing: https://w3.org/TR/WCAG21/#text-spacing
* Accessibility section from thinkR book: https://engineering-shiny.org/ux-matters.html#web-accessibility
* ANDI: https://www.ssa.gov/accessibility/andi/help/install.html
* Shiny Assistant: https://shiny.posit.co/blog/posts/shiny-assistant/



## Questions to consider

* How can you make option-grouped selectizeInputs() accessible? pickerInputs are performing fine. Problem on one of our webpages, from the assessment: "In this filter, there are visual elements present in a list, but they are not in a list with each having its own role=option element."
* Can you share some best practices for using ARIA elements?
* Do you know how to add alt text to leaflet polygons? Did you have to use javascript?
* I'm not sure if this is considered accessibility related, but does anyone know if there is a way to have a toggle that could translate text on the page between english and spanish?

## Our observations

* Generally, there was confusion between alt text and aria labels - functionally they are the same.

