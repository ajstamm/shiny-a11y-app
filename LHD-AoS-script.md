Web Accessibility in Online Dashboard Design, LHD Academy of Science National Conference, Virtual, January 29, 2025
https://lhdacademyofscience.org/aos-national-conference/
Video: 
• Abby Stamm, Senior Health Informatician, Office of Data Strategy and Interoperability, Data Technical Assistance Unit, Minnesota Department of Health 
• Eric Kvale, Senior Data Scientist, Retention Compliance, Office of Data Strategy and Interoperability, Data Technical Assistance Unit, Minnesota Department of Health (replaced by Angela Noll, data navigator)
• Analise Dickinson, Data Scientist, Office of Data Strategy and Interoperability, Data Technical Assistance Unit, Minnesota Department of Health 
This presentation will discuss Web Content Accessibility Guidelines (WCAG) standards in online dashboard design. We will cover the WCAG standards relevant for dashboard design and why they are important. We will provide examples of ways we have met them. We will also introduce dashboard features in Shiny that 
go above and beyond current WCAG guidelines. 
Participants will... 
• Gain an understanding of Web Content Accessibility Guidelines (WCAG) standards relevant to online dashboard design. 
• Explore the importance of incorporating WCAG standards to create inclusive and accessible dashboards. 
• Examine real-world examples of how WCAG standards have been successfully implemented in dashboard design. 


----------------------------------

Presenters: Analise, Angela, Abby
Date: 29 January 2025
Title: Web Accessibility in Online Dashboard Design

I will demonstrate two dashboards. Both were built using Shiny.
The first dashboard illustrates the web content accessibility guidelines covered 
by Analise.
The second dashboard illustrates additional accessibility features to support 
users who are blind or have low vision.


# Dashboard: WCAG with penguins

Dashboard purpose: to illustrate WCAG standards

If you use R, you can clone this dashboard from 
https://github.com/tidy-MN/shiny-a11y-app/tree/master/penguins
It is not hosted online, so you will need to run it in your own instance of R.


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
    - ANDI

search source: 
<img src="https://allisonhorst.github.io/palmerpenguins/logo.png" alt="palmer penguins R package logo"/>


### Individual data tab

* 2.1.1 Keyboard Navigation (A) 
    - tab, shift tab, arrows
* 2.4.3 Focus Order (A) 
    - note top to bottom, left to right
    - ANDI
* 2.4.7 Keyboard Focus Visible (AA)
    - note black outline



### Plots tabs

bar: 

* 1.4.1 Non-text Use of Color (A) 
    - colors work for greyscale and color blind
    - introduce colorbrewer
* 1.4.11 Non-Text Color Contrast (AA)
    - adelie too light - blends into background - add border
    - border and darkest color blend - fine, not informative
    - textures - note pattern size
* 1.4.13 Content on Hover or Focus (AA)
    - tables (optional download)

line: 

* 1.4.1 Non-text Use of Color (A) 
    - lines only maybe hard to understand - add markers (find hovers)
* 1.4.11 Non-Text Color Contrast (AA)
    - Adelie still hard to see - dark palette (greyscale, colorblind okay)
    - line patterns, then marker patterns
* 1.4.13 Content on Hover or Focus (AA)
    - tables (optional download)



### Text formatting tab

* 1.4.3 Text Color Contrast (Minimum) (AA) 
    - threshold above 18pt as Analise described
    - orange vs purple
* 1.4.4 Resize Text (AA)
    - text box change to show versatility
    - zoom for whole browser
* 1.4.12 Text Spacing (AA)


# Questions?


# Dashboard: Sound and texture with penguins

Purpose of dashboard: demonstrate advanced features for blind and visually 
impaired users

* sonify: convert graphics to sound
* BrailleR: convert graphics to text
* tactileR: make graphics readable by feel


### sonify

Start with normal distribution to understand how sonify works
Can modify sound duration and frequency ranges

Examples: 
* chinstrap, x = bill length, y = bill depth, 5 degrees
* adelie, x = flipper length, y = bill length, 5 degrees

### BrailleR

BrailleR converts graphics to text
Select penguin and measurement

histogram:
This histogram that is visible to sighted users
below it BrailleR produced a text description of the histogram

Note this is too much text for aria or alt text in a plot description,
but you could use a similar process to auto-generate that description, 
which would accommodate dynamic charts

Note how the text changes when I change the measurement
The last part, the mids and counts for bins, would work better in a table

boxplot:
The text produced by BrailleR for the boxplot is different than the histogram 
text, but still long for alt text

To provide some of this information another way, a list may work better



### tactileR

tactileR creates simple PDFs that can be printed
Clicking the link below the histogram (textualization tab) generates the PDF
(open the downloaded PDF)
After printing this, you can run it through a swell form machine
and all black portions will be embossed
This one-minute video shows the process

This dashboard introduces a few advanced accessibility features that I hope you 
will consider looking into when displaying data on your website or dashboard

Now I will hand control to Angela for the Q&A



