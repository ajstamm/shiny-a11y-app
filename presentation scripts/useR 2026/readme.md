---
title: "Make your Shiny dashboard screen reader friendly"
format: 
  html:
    toc: true
    toc-expand: 1
    toc-location: left
    toc-depth: 3
    page-layout: full
---

## Introduction

This demonstration begins with a draft dashboard called "Fun with  Irises", 
which displays data from the `iris` dataset included with R. 
The purpose of this demonstration is to introduce you to relatively easy to
implement solutions for select accessibility issues that I have encountered 
when designing my own dashboards. 

What this demonstration does *not* cover:

1. Ensuring language, vocabulary, and messaging are audience appropriate.
1. Testing for keyboard navigation.
1. Testing for appropriate font and colors in charts.
1. Using sound and texture to make your content more accessible. 
    For an example of how to implement the R packages
    [`tactileR`](https://github.com/jooyoungseo/tactileR) and 
    [`sonify`](https://cran.r-project.org/package=sonify), 
    see the code for my 
    [texture-sound app](https://github.com/ajstamm/shiny-a11y-app/tree/master/texture-sound).

## Files included

1. [Non-accessible app](nonaccessible_app.R): 
    Download this file if you want to practice adding the fixes described below to your own app.
1. [Final accessible app](final_accessible_app.R): 
    This file already includes all of the fixes described below. Use it to check your work.
1. [Abstract](useR_2026_abstract.md): 
    This file contains the abstract and notes for the demonstration.
1. [Introduction and conclusion slides](useR_2026_slides.pdf): 
    PDF of the introduction and conclusion slides.

## The dashboard

The "Fun with Irises" dashboard includes three tabs and a sidebar. 
The tabs include:

* Introduction. This tab is text only, with no interactive elements.
* Barplot. This tab includes a bar plot that can be modified using 
    the first three filters in the sidebar.
* Histogram. This tab includes a histogram that can be modified using 
    all of the filters in the sidebar.
    
Download the [Non-accessible app](nonaccessible_app.R) to run the dashboard. 
Use this file if you want to practice the demonstration content yourself. 

## Accessibility testing tools

There are several free tools that can be used to test for accessibility in 
Shiny dashboards. We have listed a few of the ones we use below.

* [`shinya11y`](https://github.com/ewenme/shinya11y) is an R package 
   for testing dashboard accessibility maintained by @ewenme on GitHub. 
* [Accessible Name and Description Inspector (ANDI)](https://www.ssa.gov/accessibility/andi/help/install.html) 
   is a bookmarklet for testing webpage accessibility maintained by 
   the US Social Security Administration. 
* [NonVisual Desktop Access (NVDA)](https://www.nvaccess.org/download/) is a 
   screen reader maintained by the non-profit NV Access.
* [Web Accessibility Evaluation Tool (WAVE)](https://wave.webaim.org/) is a 
   suite of tool maintained by Web Accessibility in Mind (WebAIM) at Utah 
   State University.

By using these tools, we have discovered several issues with accessing information.

## Accessibility review results

For this demonstration, we will review the following issues.

1. Screen reader users cannot access some content.
    1. The dashboard's language is not defined.
    1. The only way to access the information in the charts is by looking at them.
    1. There is no alternative text for charts.
2. Content is unclear or hard to understand.
    1. There are no descriptions or explanations for the charts.
    1. The filters are labelled only with vague keywords.

This demonstration will cover how to address each of the above issues in turn.

## 1. Solutions to address screen reader issues

### 1.i. Define the dashboard language

This fix is easy. I have added it to my dashboard template so that unless I am
working on a non-English dashboard, I never need to think about it again.

In the UI settings, add the line, `tags$html(lang = "en")`. 

If you want to add a language other than English, one place you can find the
correct tag is by using the 
[Language subtag lookup app](https://r12a.github.io/app-subtags/).

To check this fix with ANDI, activate ANDI, choose "Structures" from the 
drop-down, expand the "more details" menu, and select "page title".


### 1.ii. Add a second way to access chart information

My preferred alternate method to display data is to include a table below each 
chart. Basic tables are accessible by screen readers. 
In a production app, I will also include a button to download the data as a 
comma-separated value (CSV) file.

In the server function, I will include a `renderDT` call for each table that 
includes the code to create the same table that is used to generate the chart.
These calls will look similar to the one below. 

```
output$bar_table <- DT::renderDT({
  d <- filtered_data() |> group_by(Species) |> summarise(Count = n())
  dt <- DT::datatable(d, rownames = FALSE, class = 'cell-border stripe',
                      options = list(paging = FALSE, searching = FALSE))
  return(dt)
})
```

Then after the chart in the appropriate tab panel, I add the code,
`dataTableOutput("bar_table")`.


### 1.iii. Add alternative text to charts

General guidance suggests that alternative (or alt) text should not be more 
than 250 characters. If your alternative text is likely to be longer than that, 
consider moving part of it to an explanatory paragraph with your chart. 
Remember, basic unformatted text is fully accessible to screen readers. 
A general guideline is that all information should be available in a table, 
the alternative text, and an accompanying paragraph, 
but details do not need to be repeated across all three.

For this example, my alternative text includes basic summary information for my 
chart and a note to review the accompanying table for more information. In all, 
my alternative text is around 120 characters long. 
Note that it does not include all of the information in the table. 

```
output$bar_plot <- renderPlot({
  d <- filtered_data() |> group_by(Species) |> dplyr::summarise(Count = n())
  ggplot(data = d, aes(x = Species, y = Count)) +
         geom_bar(stat = "identity", fill = "#003865") +
         labs(title = "Frequency chart of iris species")
  },
  alt = reactive({
    d <- filtered_data()
    aria <- paste("Barplot of", input$species, "irises filtered on", 
                  min(d$measure), "to", max(d$measure), input$measure, ".",
                  "Refer to the table below the chart for values displayed.")
    return(aria)
  }))
```

The `alt` tag above assigns the text that the screen reader will read when it 
reaches the chart.

To check this fix with `shinya11y` and a mouse, click on the spectacles in the lower left, then click "Screen Reader Wand". Hover over the chart and read the alternate text in the wand window.


## 2. Solutions for issues with understanding

### 2.i. Add chart explanations

Text explanations for charts are useful for reducing the amount of information 
you need to include in alternative text. 
They are also useful for people who have trouble reading charts. 
Ideally your explanation should include why the chart matters and 
what you want the user to take away from it. 

In this example, the point is for you to learn the code, 
not to create a production-ready dashboard with a specific purpose, 
so the chart description here is not very meaningful.

```
output$hist_desc <- shiny::renderText({
  d <- filtered_data()
  desc <- paste("This histogram shows", input$measure, "ranging from", 
                min(d$measure), "to", max(d$measure), "cm for", input$species, 
                "irises. The median is", median(d$measure), "cm and the mean is",
                round(mean(d$measure), digits = 2), "cm.")
  return(paste("<p>", HTML(desc), "</p>"))
})
```

Then before the chart in the appropriate tab panel, I add the code,
`htmlOutput("hist_desc")`.


### 2.ii. Clearly define all filters

Filters of only one or two words may not be understandable to the user. 
Any time you require user input, ensure your request is clear. 
For example, instead of requesting "Height", consider if one of the following 
would work better.

* Enter your estimated height in inches as a whole number
* Your height without shoes in centimeters
* Your height at your last doctor's visit in feet

In the sidebar filter, "Measure" is a vague, unclear term. 
Let's modify it to clarify what we are asking.

```
selectInput("measure", selectize = FALSE,
            label = "Select the measurement to filter on for the chart:", 
            choices = names(iris)[1:4], selected = names(iris)[1])
```






