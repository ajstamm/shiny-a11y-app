# Equity Week 2024

This outline is for the presentation [Creating Accessible Dashboards Using R Shiny](https://mn.gov/dhs/equity-week/?trumbaEmbed=view%3Devent%26eventid%3D176589731) offered online at 1pm on Friday, 27 September 2024.

For specific details on each item, see the [WCAG guidelines at W3.org](https://www.w3.org/WAI/WCAG22/quickref/).

## Introductions: Abby & Eric


## Text criteria: Abby

About tab:

* 1.4.12 Text Spacing (AA)  
  - Tab: text formatting; Item: letter spacing filter
* 1.4.4 Resize Text (AA)
  - Tab: text formatting; Item: font size filter
* 1.4.3 Text Color Contrast (Minimum) (AA) 
  - Tab: text formatting
    - Item: font size filter
    - Example: font color matrix
    - Note: 3:1 for large font (18 pt font and larger) and 4.5:1 for regular font
* Note: font can be defined, but user may not have it installed
  - better to define only serif or sans serif


## Non-text criteria: Eric

Plots tabs: 

* 1.4.1 Non-text Use of Color (A) 
  - patterns and symbols
* 1.4.11 Non-Text Color Contrast (AA)
* 1.4.13 Content on Hover or Focus (AA)

About tab:

* 1.1.1 Non-text Content (A) 


## Navigation criteria

Manipulate window size: Abby

* 1.4.10 Reflow (AA)
  - also zoom

Keyboard tabbing (tables): Abby

* 2.1.1 Keyboard Navigation (A) 
  - Tab: Individual data; Item: sidebar, table
* 2.4.3 Focus Order (A) 
  - Tab: Individual data; Item: table chevron
* 2.4.7 Keyboard Focus Visible (AA)
  - Tab: Individual data; Item: cell highlighted

Screen reading (tables?): Eric

* 1.3.2 Meaningful Sequence (A)
* 2.4.6 Headings and Labels (AA)
  - will not note italic or bold
  - identify headings with proper syntax
* 2.4.4 Link Purpose (In Context) (A)
  - added to introduction tab
* Braille and _sonify_ dashboard

## Site use criteria: Eric

* 1.3.5 Identify Input Purpose (AA) 
  - what user should enter
* 3.2.2 Content Change On Input (A) 
  - Instructions include when content changes
  - Change only on user request is 3.2.5 (AAA) 
* 3.3.2 Labels or Instructions (A)

## General criteria: Abby

General layout:

* 3.2.3 Consistent Navigation (AA)
  - Navigation elements are displayed in the same order across tabs
* 3.2.4 Consistent Identification (AA)
  - All inputs of the same type work the same way
* 2.4.2 Page Titled (A) 
  - Browser tab label
* 3.3.1 Error Identification (A)
  - Tab: Bar chart; Item: filter on Gentoo and Dream
    - Failure: textured bar chart
    - Success: plain bar chart
* 1.3.3 Sensory Characteristics (A)
  - Tab: Bar chart; Item: plotly icons
    - Issue: no non-hover text equivalent and uninformative ARIA text
    - Possible solution: can be deactivated


## Summary: 

## Questions?




