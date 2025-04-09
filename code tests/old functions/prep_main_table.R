#' Prepare filtered table
#' 
#' @param d     Dataset
#' @param input List of user inputs
#' 
# test code
# df <- readRDS("vs_app/data/pregnancy.Rds")
# l <- list(content = "Pregnancy", topic = "State", measure = "Number of Live Births", 
#           year = NULL, content = NULL, variable = "Pregnancies")
# p <- prep_main_table(d = df, input = l)
# 


prep_main_table <- function(d, input) {
  if (!is.null(input$topic) && !input$topic == "All" & 
      !is.null(input$variable) && !input$variable == "All") {
    d <- d |>
      dplyr::filter(Topic == input$topic, 
                    Variable == input$variable)
    if (input$content == "Pregnancy") {
      if (grepl(" Rate", input$measure)) {
        d <- d |> dplyr::filter(Measure == input$measure) |> 
          dplyr::select(-Count)
      } else {
        d <- d |> dplyr::filter(!grepl("Rate", Measure)) |> 
          dplyr::select(-Value)
      }
    }
    if (input$content %in% c("Birth counts", "Mother's risk factors")) {
      if (!is.null(input$year) && !input$year == "All") {
        d <- d |> dplyr::filter(Year == input$year) 
      }
    }
  } else {
    d <- data.frame()
  }
  
  return(d)
}

# d <- cln$birth_counts.Rdsx
# input <- list(content = "Birth counts", measure = "Count", year = 2022, 
#               topic = "Place of Birth", variable = "City")
# t <- prep_main_table(d, input)
