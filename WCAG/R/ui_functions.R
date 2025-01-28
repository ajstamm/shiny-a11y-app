# author: Abby Stamm
# date: August 2024
# purpose: functions for sample dashboard

sidebar <- function(df) {
  sidebarPanel(
    h3("Instructions"),
    p("Please select your desired filters from the options provided for each 
       tab. Content will update as you make changes."),
    br(), br(),
    # tab_text ----
    conditionalPanel(condition = "input.my_tabs == 'tab_text'",
      textInput("font_size", placeholder = "12px", value = "12px", 
                label = p("Enter desired font size in pixels:")),
      textInput("letter_spacing", placeholder = "1px", value = "1px", 
                label = p("Enter desired letter spacing in pixels:")),
      selectInput("text_color", label = p("Select desired font color:"),
                  choices = c("black", "red", "orange", "yellow", "green", 
                              "blue", "purple", "white"), 
                  selectize = FALSE, selected = "black")
    ),
    # tab_indiv, tab_sum, tab_line, or tab_bar ----
    conditionalPanel(condition = "input.my_tabs == 'tab_indiv' |
                                  input.my_tabs == 'tab_sum' |
                                  input.my_tabs == 'tab_line' |
                                  input.my_tabs == 'tab_bar'", # Individual data
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
      strong("Filter by penguin weight in grams:"),
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
    # tab_bar or tab_line ----
    conditionalPanel(condition = "input.my_tabs == 'tab_bar' | 
                                  input.my_tabs == 'tab_line'",
      selectInput("chart_label", label = HTML("Would you like to label values?"),
                  choices = c("No", "Yes"), selectize = FALSE, selected = "No"),
      selectInput("chart_palette", label = HTML("Select desired color palette:"),
                  choices = c("Blues", "Greens", "Greys", "Oranges", "Purples",
                              "Reds", "Dark2"), 
                  selectize = FALSE, selected = "Blues")
    ),
    # tab_bar ----
    conditionalPanel(condition = "input.my_tabs == 'tab_bar'",
      selectInput("bar_fill", label = HTML("Select desired fill type:"),
                  choices = c("Plain", "Textured"), 
                  selectize = FALSE, selected = "Plain"), 
      selectInput("bar_border", label = HTML("Select desired border color:"),
                  choices = c("black", "red", "orange", "yellow", "green", 
                              "blue", "purple", "white"), 
                  selectize = FALSE, selected = "white"), 
    ),
    # tab_line ----
    conditionalPanel(condition = "input.my_tabs == 'tab_line'",
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
    tabsetPanel(id = "my_tabs", 
      # tab_about ----
      tabPanel(title = "About data", value = "tab_about",
        h2("About the Palmer Penguins data"),
        p("These data are from a study in Antarctica. Data on penguins are 
           publicly available through the", em("palmerpenguins"), 
          "R package. Data for names, foods, and swim speeds were fabricated 
           for an", 
          a(href = "https://tidy-mn.github.io/R-camp-penguins/", "RCamp"), 
          "exercise."), br(), 
        img(src="https://allisonhorst.github.io/palmerpenguins/logo.png",
            alt="palmer penguins R package logo"), br(), br(),
        p("For more information, see:"),
        uiOutput("sources_list"),
        p("This dashboard was created by", 
          a(href = "https://github.com/ajstamm", "Abigail Stamm"),
          "as an example dashboard for", 
          a(href = "https://mn.gov/dhs/equity-week/", "MN DHS Equity Week 2024"), 
          "and was used in the presentations", 
          em("Making data visualizations accessible"), "and", 
          em("Creating accessible dashboards using R Shiny.")),
      ),
      # tab_indiv ----
      tabPanel(title = "Individual data", value = "tab_indiv", br(), br(),
        DT::dataTableOutput("all_penguins")),
      # tab_sum ----
      tabPanel(title = "Summary data", value = "tab_sum", br(), br(),
        DT::dataTableOutput("sum_penguins")),
      # tab_bar ----
      tabPanel(title = "Bar chart", value = "tab_bar", br(), br(),
        conditionalPanel(condition = "input.bar_fill == 'Plain'",
                         plotly::plotlyOutput("bar_plain")),
        conditionalPanel(condition = "input.bar_fill == 'Textured'",
                         shiny::plotOutput("bar_texture")),
        br(), br(), br(),
        dataTableOutput("bar_table"), br(), br(), br()
      ),
      # tab_line ----
      tabPanel(title = "Line chart", value = "tab_line", br(), br(),
        plotly::plotlyOutput("line_chart"), br(), br(), br(),
        dataTableOutput("line_table"), br(), br(), br()),
      # tab_text ----
      tabPanel(title = "Text formatting", value = "tab_text", br(), br(), 
        htmlOutput("text_play"), 
        DT::dataTableOutput("font_matrix"), br(), br())
    )
  )
}

