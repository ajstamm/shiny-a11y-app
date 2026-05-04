Title: Make your Shiny dashboard screen reader friendly

Online dashboards use data visualizations to quickly convey information. Interactive elements like charts and data filters often display additional information not accessible by screen readers. Accessibility features improve the overall presentation and user experience by augmenting, amplifying, and enhancing the content so that users can interact with and understand the same content in multiple ways, depending on their needs and preferences.

Our presentation will demonstrate in a simple Shiny dashboard how to address several accessibility issues that someone who uses a screen reader might encounter. We will briefly introduce the dashboard, then we will cover each of the failed checks. For each check, we will demonstrate the issue, show a way to revise the dashboard code to address it, and demonstrate how the check passes on the fixed dashboard.

The failed checks include the following.

1. The dashboard's language is not defined.
2. The filters are labelled only with vague keywords.
3. The only way to access the information in the charts is by looking at them.
4. There are no descriptions or explanations for the charts.
5. There is no alternative text for charts.

All files, including the presentation, starting script, and suggested solution script, will be downloadable from the GitHub repository https://github.com/ajstamm/shiny-a11y-app for attendees who wish to code along. Our past presentations on accessibility in Shiny dashboards can also be found here.


