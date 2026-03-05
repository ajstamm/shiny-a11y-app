# ShinyConf 2025

**Registration:** https://sessionize.com/shiny-conf-2025/   
**Due date:** February 9   
**Resources:** For specific details on each item, see the WCAG guidelines at W3.org.

**Title:** Designing Inclusive Shiny Dashboards: Accessibility Best Practices and Innovations   
**Proposed topic:** "Modern App Design: Showcases of aesthetically and functionally advanced Shiny apps."   
**Level:** Intermediate?   
**Proposed type:** 1.5 hour workshop  

[Slides on SharePoint](https://mn365.sharepoint.com/:p:/r/sites/MDH/datata/Shared%20Documents/Accessibility%20Resources/ShinyConf%202025/ShinyConf%20Presentation%202025.pptx)

---

# Abstract

**Talking points:**

* Importance of accessible content. 
* What accessible looks like. 
* General accessibility strategies.
* Beyond WCAG: Shiny-specific accessibility strategies.

**Requirement:** Up to 250 words; below is 196 words


Online dashboards use data visualizations like charts and maps to quickly convey information. Interactive elements like data filters and pop-up boxes often display additional information not visible in the static image. Navigating these elements often relies on a mouse and may not be possible by keyboard.
 
Data visualization is often not accessible to those with vision impairments. When interactive elements update information in real time, they do not reliably update the labeling read by screen readers, which limits screen reader users’ access to information. Often screen readers and keyboards cannot access pop-ups at all.
 
Accessibility features improve the overall presentation and user experience by adding functionality. These features augment, amplify, and enhance the content. This allows users to interact with and understand the same content in multiple ways, depending on their needs and preferences.
 
This session will cover accessibility best practices that we are implementing in dashboard design for our Shiny dashboards in the Minnesota Department of Health Office of Data Strategy and Interoperability. We will demonstrate using sound, braille, keyboard navigation, dynamic content, and aria text in dashboard design. We will also demonstrate using some accessibility testing tools, including recent artificial intelligence advancements.

---

# Outline

## (2-3 min) Introductions: Abby, Eric

* Tim and Will can review, won't present


## Powerpoint (20 min?)

* Why accessibility
* Dashboard questions
* WCAG - R specific
* Assistive technology?


## WCAG demo

### Keyboard Navigation

Tables tab:

* 2.4.3 Focus Order (A)
  * Keyboard tabbing order
* 2.4.7 Keyboard Focus Visible (AA)
* 2.1.1 Keyboard Navigation (A)
* 1.3.2 Meaningful Sequence (A)
  * ANDI


### Non-text color

Bar plot tab:

* 1.4.1 Non-text Use of Color (A)
    * Patterns
* 1.4.11 Non-Text Color Contrast (AA)
    * bar borders
* 1.4.13 Content on Hover or Focus (AA)
    * 

Line chart tab:

* 1.4.1 Non-text Use of Color (A)
    * Symbols and line type
* 1.4.11 Non-Text Color Contrast (AA)
* 1.4.13 Content on Hover or Focus (AA)

### Text criteria

Text formatting tab:

* 1.4.12 Text Spacing (AA)
* 1.4.4 Resize Text (AA)
* 1.4.3 Text Color Contrast (Minimum) (AA)

Text guidelines:

* 3:1 for large font (18 pt font and larger) and 4.5:1 for regular font
    * User can zoom in, so test readability/viewability up to 400%
* Font can be defined, but user may not have it installed, so don't
    * Better to define only serif or sans serif font
* do not define text spacing 
    * allow user to override default
    * helps users with dyslexia and similar reading issues



### Screen reading

About tab:

* 2.4.6 Headings and Labels (AA)
    * ANDI
    * inspection > accessibility
* 2.4.4 Link Purpose (In Context) (A)
    * provide direct link or link to descriptive word/phrase
    * avoid "click here" and other vague language

Screen reading guidelines:

* Will not note italic, bold, or color
* Identify headings with proper syntax
* Be careful about repeating visible text in aria/alt
* keep aria/alt short and purposeful



### Site use criteria

* 3.3.2 Labels or Instructions (A)
    * how should user interact with your site? 
    * what do different tabs/panels contain?
* 1.3.5 Identify Input Purpose (AA)
    * What user should enter
    * what's required
* 3.2.2 Content Change On Input (A)
    * this should be consistent and made known so user expects it

content only changes when the user expects it
change only on user request is 3.2.5 (AAA)

### General display

About tab:

* Navigation criteria
* Manipulate window size
* 1.4.10 Reflow (AA)
* Zoom


### General layout

* 3.2.3 Consistent Navigation (AA)
* 3.2.4 Consistent Identification (AA)
* 2.4.2 Page Titled (A)
    * browser tab label and dashboard title


### Acessibility fails

* 3.3.1 Error Identification (A)
    * filter on Gentoo and Dream, for example
        * failure: bar chart
        * success: empty table

* 1.3.3 Sensory Characteristics (A)
    * unlabeled plotly icons fail
        * no non-hover text equivalent and uninformative ARIA text
        * can be deactivated



## Extras demo

sonify
BrailleR
tactileR
colorspace
shinya11y


