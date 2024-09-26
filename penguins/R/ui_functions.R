# author: Abby Stamm
# date: August 2024
# purpose: functions for sample dashboard

sidebar <- function(df) {
  sidebarPanel(
    h3("Instructions"),
    HTML(paste("Please select your desired filters from the options provided",
               "for each tab.",
               "Content will update as you make changes.")),
    br(), br(),
    conditionalPanel(condition = "input.tabs == 'Text formatting'",
      textInput("font_size", placeholder = "12px", value = "12px", 
                label = HTML("Enter desired font size in pixels:")),
      textInput("letter_spacing", placeholder = "1px", value = "1px", 
                label = HTML("Enter desired letter spacing in pixels:")),
      selectInput("text_color", label = HTML("Select desired font color:"),
                  choices = c("black", "red", "orange", "yellow", "green", 
                              "blue", "purple", "white"), 
                  selectize = FALSE, selected = "black")
    ),
    conditionalPanel(condition = "input.tabs == 'Individual data' |
                                  input.tabs == 'Summary data' |
                                  input.tabs == 'Bar chart' |
                                  input.tabs == 'Line chart'",
      selectInput("species", label = "Select desired species:", 
                  choices = c("All", unique(df$species)),
                  selectize = FALSE, selected = "All"),
      selectInput("study_name", label = "Select desired study:",
                  choices = c("All", unique(df$study_name)),
                  selectize = FALSE, selected = "All"),
      selectInput("sex", label = "Select desired sex:",
                  choices = c("All", unique(df$sex)), 
                  selectize = FALSE, selected = "All"),
      # selectInput("island", label = "What island should be selected?",
      #             choices = c("All", unique(penguins$island)), 
      #             selectize = FALSE, selected = "All"),
      radioButtons("island", label = "Select desired island:",
                   choices = c("All", unique(df$island)), selected = "All"),
      dateRangeInput("date_range", label = "Filter by date egg hatched:",
                     start = min(df$date_egg), end = max(df$date_egg),
                     min = min(df$date_egg) - 5, max = max(df$date_egg) + 5),
      HTML("<h5><b>Filter by penguin weight in grams:</b></h5>"),
      # text input boxes
      splitLayout(
        textInput("g_min", label = HTML("Enter minimum <br/> weight:"), 
                  value = paste0(formatC(min(df$body_mass_g, na.rm = TRUE),
                                 format = "f", big.mark = ",", digits = 0), "g"),
                  placeholder = "0g"),
        textInput("g_max", label = HTML("Enter Maximum <br/> weight:"), 
                  value = paste0(formatC(max(df$body_mass_g, na.rm = TRUE),
                                 format = "f", big.mark = ",", digits = 0), "g"), 
                  placeholder = "0g"),
      )
    ),
    conditionalPanel(condition = "input.tabs == 'Bar chart' | 
                                  input.tabs == 'Line chart'",
      selectInput("chart_label", label = HTML("Would you like to label values?"),
                  choices = c("No", "Yes"), 
                  selectize = FALSE, selected = "No"),
      selectInput("chart_palette", label = HTML("Select desired color palette:"),
                  choices = c("Blues", "Greens", "Greys", "Oranges", "Purples",
                              "Reds", "Dark2"), 
                  selectize = FALSE, selected = "Blues")
    ),
    conditionalPanel(condition = "input.tabs == 'Bar chart'",
      selectInput("bar_fill", label = HTML("Select desired fill type:"),
                  choices = c("Plain", "Textured"), 
                  selectize = FALSE, selected = "Plain"), 
      selectInput("bar_border", label = HTML("Select desired border color:"),
                  choices = c("black", "red", "orange", "yellow", "green", 
                              "blue", "purple", "white"), 
                  selectize = FALSE, selected = "white"), 
    ),
    conditionalPanel(condition = "input.tabs == 'Line chart'",
      selectInput("line_display", label = HTML("Select desired line display:"),
                  choices = c("Lines", "Lines + Markers", "Markers"), 
                  selectize = FALSE, selected = "Lines"),
      radioButtons("line_type", label = HTML("Should lines vary?"),
                   choices = c("Yes", "No"), selected = "No"),
      radioButtons("marker_type", label = HTML("Should markers vary?"),
                   choices = c("Yes", "No"), selected = "No"),

    ),

    # Clear All Filters Button
    # actionButton("clear_all", "Clear All Filters", class = "btn-primary"),
  )
}

main <- function(df) {
  mainPanel(
    tabsetPanel(id = "tabs", 
                tabPanel("About data", 
                         h2("About the Palmer Penguins data"),
                         p(HTML("These data are from a study in Antarctica. 
                                Data on penguins are publicly available through 
                                the <i>palmerpenguins</i> R package.
                                Data for names, foods, and swim speeds were 
                                made up for an
                <a href='https://tidy-mn.github.io/R-camp-penguins/'>RCamp</a>
                                exercise.")),
                         br(), 
                         htmlOutput("sources"),
                         p(HTML("This dashboard was created by 
                                <a href='https://github.com/ajstamm'>Abigail 
                                Stamm</a>
                                as an example dashboard for the presentations 
                                <i>Making data visualizations accessible</i> 
                                and <i>Creating accessible dashboards using 
                                R Shiny</i> as part of
                                <a href='https://mn.gov/dhs/equity-week/'>MN 
                                DHS Equity Week 2024</a>."))),
                tabPanel("Individual data", br(), br(),
                         DT::dataTableOutput("all_penguins")),
                tabPanel("Summary data", br(), br(),
                         DT::dataTableOutput("sum_penguins")),
                tabPanel("Line chart", br(), br(),
                         plotly::plotlyOutput("line_chart"),
                         br(), br(), br(),
                         dataTableOutput("line_table"),
                         br(), br(), br()),
                tabPanel("Bar chart", br(), br(),
                  conditionalPanel(condition = "input.bar_fill == 'Plain'",
                                   plotly::plotlyOutput("bar_plain")),
                  conditionalPanel(condition = "input.bar_fill == 'Textured'",
                                   shiny::plotOutput("bar_texture")),
                  br(), br(), br(),
                  dataTableOutput("bar_table"),
                  br(), br(), br()
                ),
                tabPanel("Text formatting",
                         br(), br(), 
                         htmlOutput("text_play"), 
                         DT::dataTableOutput("font_matrix"),
                         br(), br())
    )
  )
}

