# UI functions

main_ui <- function() {
    tabsetPanel(
    ## About Tab ----
    tabPanel("About",
             h3("About This App"),
             p("This application showcases how R can be leveraged for 
                accessibility, particularly for users who are visually 
                impaired. By using tools such as data sonification, 
                textualization, and tactualization, we can offer alternative
                methods for engaging with data."),
             
             p("R provides a wide range of accessibility-focused libraries that
                extend the capabilities of traditional data science tools."),
             
             h4("Packages Featured in This App"),
             
             ### Sonify ----
             tags$strong("Sonify:"), 
             p("The 'sonify' package converts data into sound. This is 
                especially useful for blind or visually impaired individuals 
                who may rely on auditory data analysis. It can turn numeric 
                data into soundscapes, helping convey trends, patterns, or
                anomalies."),
             tags$a(href = "https://rdrr.io/cran/sonify/", 
                    "View the sonify package on rdrr.io.", target = "_blank"),
             p(""),

             ### BrailleR ----
             tags$strong("BrailleR:"), 
             p("The 'BrailleR' package provides text-based descriptions of 
                graphs, making R visualizations accessible to screen readers. 
                It also offers support for creating graphs that are optimized 
                for tactile or auditory formats."),
             tags$a(href = "https://github.com/ajrgodfrey/BrailleR", 
                    "View the BrailleR package on GitHub.", target = "_blank"),
             p(""),
             
             ### TactileR ----
             tags$strong("TactileR:"), 
             p("The 'tactileR' package converts R graphics into Braille-ready 
                PDFs for tactualization, allowing users to physically feel the 
                data. This package is useful for blind or visually impaired 
                users who rely on tactile feedback to interpret information."),
             tags$a(href = "https://github.com/jooyoungseo/tactileR", 
                    "View the tactileR package on GitHub.", target = "_blank"),
             p(""),
             
             h4("Other Use Cases"),
             p("The accessibility tools featured in this app demonstrate R’s
                potential to offer accessible data science tools to all users.
                Other possible use cases include creating auditory data 
                dashboards for visually impaired users, integrating haptic 
                feedback devices for tactile data interpretation, and building
                interactive auditory learning modules.")
    ),
    
    ## Sonification Tab ----
    tabPanel("Sonification (sonify)",
             h3("Data Sonification"),
             
             # Sonification controls and output
             p("Data sonification converts data into sound, allowing visually
                impaired users to interpret data patterns through auditory cues.
                The 'sonify' package helps convert numerical data into sound."),
             
             # GitHub link to the sonify package
             tags$a(href = "https://rdrr.io/cran/sonify/", 
                    "Learn more about the 'sonify' package on rdrr.io.", 
                    target = "_blank"),
             
             br(),
             
             ### sonify dnorm ----
             p("In this example, we use a normal distribution created by 
                dnorm() to demonstrate sonification."),
             
             # Plot output for normal distribution
             plotly::plotlyOutput("normal_dist_plot", height = "400px", 
                                  width = "100%"),
             
             # Button to play normal distribution sonification
             selectInput("duration_sonify", 
                         "Select sound duration in seconds:", 
                         choices = seq(from = 5, to = 60, by = 5), 
                         selected = 10),
             # on frequency: 
             # https://boomspeaker.com/what-are-lows-mids-and-highs/
             # https://www.whippedcreamsounds.com/audio-spectrum/
             selectInput("freq_high_sonify", 
                         "Select upper frequency in Hertz:", 
                         choices = seq(from = 600, to = 1000, by = 50), 
                         selected = 800),
             actionButton("play_sonify_normal", 
                          "Play Sonification of Normal Distribution", 
                          class = "btn btn-primary"),
             
             br(),
             br(),
             
             ### sonify penguins ----
             # Penguin image
             img(src = "culmen.png", 
                 alt = "The length of a Penguin bill identifying the culmen area",
                 # Reduced image size and added margin
                 style = "width:25%; margin-bottom: 20px;"),  
             
             p("You can also convert the penguin dataset into sound. Below, 
                the chart displays a fitted model for select measurements by
                species."),
             selectInput("species_sonify", 
                         "Select Penguin Species (if applicable):", 
                         choices = c("All Penguins", 
                                     "Adelie Penguin", 
                                     "Chinstrap Penguin", 
                                     "Gentoo Penguin"), 
                         selected = "All Penguins"),
             selectInput("x_sonify", 
                         "Select x-axis variable:", 
                         choices = c("Bill Length (mm)" = "bill_length_mm",
                                     "Bill Depth (mm)" = "bill_depth_mm",
                                     "Flipper Length (mm)" = "flipper_length_mm",
                                     "Body Mass (g)" = "body_mass_g"), 
                         selected = "Bill Length (mm)"),
             selectInput("y_sonify", 
                         "Select y-axis variable:", 
                         choices = c("Bill Depth (mm)" = "bill_depth_mm",
                                     "Bill Length (mm)" = "bill_length_mm",
                                     "Flipper Length (mm)" = "flipper_length_mm",
                                     "Body Mass (g)" = "body_mass_g"), 
                         selected = "Bill Depth (mm)"),
             selectInput("degrees_sonify", 
                         "Select degrees for the fitted model:", 
                         choices = 2:5, selected = 3),
             actionButton("play_sonify_penguin", 
                          "Play Sonification of Penguin Data", 
                          class = "btn btn-primary"),
             
             # Plot output for penguin data sonification
             plotly::plotlyOutput("sonify_penguin_plot", 
                                  height = "500px", width = "100%"),
             downloadButton(outputId = "download_model", 
                            label = "Download tactile chart", 
                            class = "accessible-download-button")
    ),
    
    ## Data Textualization (BrailleR) Tab ----
    tabPanel("Data Textualization (BrailleR)",
             h3("Data Textualization"),
             p("The 'BrailleR' package provides text-based descriptions of R 
                plots, making them accessible to visually impaired users. This 
                is particularly useful for screen readers, providing detailed
                explanations of plots that would otherwise be visual."),
             
             # GitHub link to the BrailleR package
             tags$a(href = "https://github.com/ajrgodfrey/BrailleR", 
                    "Learn more about the 'BrailleR' package on GitHub.", 
                    target = "_blank"),
             
             br(),
             
             p("Below, we show examples of how histograms and boxplots are
                textualized."),
             
             selectInput("species_brailler", 
                         "Select Penguin Species (if applicable):", 
                         choices = c("All Penguins", 
                                     "Adelie Penguin", 
                                     "Chinstrap Penguin", 
                                     "Gentoo Penguin"), 
                         selected = "All Penguins"),
             selectInput("x_brailler", 
                         "Select x-axis variable:", 
                         choices = c("Bill Length (mm)" = "bill_length_mm",
                                     "Bill Depth (mm)" = "bill_depth_mm",
                                     "Flipper Length (mm)" = "flipper_length_mm",
                                     "Body Mass (g)" = "body_mass_g"), 
                         selected = "Bill Length (mm)"),

             ### Histogram textualization ----
             h4("Example: Histogram"),
             # Adjusted plot size
             plotOutput("hist_plot", height = "500px", width = "700px"),
             downloadButton(outputId = "download_histogram", 
                            label = "Download tactile chart", 
                            class = "accessible-download-button"),  
             
             # Bootstrap container for text output
             div(class = "container",
                 h5("BrailleR Textual Description:"),
                 # Display the alt text generated by BrailleR
                 htmlOutput("hist_description")  
             ),
             
             p("When thinking about accessibility, consider the best way to 
                convey the information. For example, the information in the 
                textual description above could also be captured in a table 
                and left out of the chart aria text."),
             
             DT::DTOutput("hist_table"),
             
             ### Boxplot textualization ----
             h4("Example: Boxplot"),
             # Adjusted plot size
             plotOutput("box_plot", height = "500px", width = "700px"),
             downloadButton(outputId = "download_boxplot", 
                            label = "Download tactile chart", 
                            class = "accessible-download-button"),  
             
             # Bootstrap container for text output
             div(class = "container",
                 h5("BrailleR Textual Description:"),
                 # Display the alt text generated by BrailleR
                 htmlOutput("box_description")
             ),
             
             p("When thinking about accessibility, consider the best way to 
                convey the information. For example, the information in the 
                textual description above could also be captured in a list 
                and left out of the chart aria text."),
             
             htmlOutput("box_summary")
    ),
    
    ## Data Tactualization (tactileR) Tab ----
    tabPanel("Data Tactualization (tactileR)",
             h3("Data Tactualization"),
             p("The 'tactileR' package converts R graphics into tactile-ready
                Braille PDFs, allowing blind users to physically feel the data.
                Tactualization is particularly useful for those who rely on 
                tactile interfaces to interpret data."),
             
             # GitHub link to the tactileR package
             tags$a(href = "https://github.com/jooyoungseo/tactileR", 
                    "Learn more about the 'tactileR' package on GitHub.", 
                    target = "_blank"),
             br(),
             
             img(src = "braille.jpg", 
                 alt = "Image of the braille alphabet.",
                 style = "width:25%; margin-bottom: 20px;"),
             
             p("You can see examples of tactileR chart outputs by clicking on 
                the buttons labelled 'Download tactile chart' on the 
                Sonification and Data Textualization tabs and locating the 
                PDFs created in your dashboard directory. These PDFs are 
                designed to be printed in black and white on swell paper. 
                All black parts of the image will be raised or embossed when 
                run through a swell machine."),
             
             p("You can watch this video for an example of creating a tactile 
                graph using a Swell Form machine:"),
             # Eric's link: https://www.youtube.com/watch?v=ClI555l4Z1M
             # new video because above is too pixelated for me
             tags$a(href = "https://www.youtube.com/watch?v=QXsByoZaEwc", 
                    "Swell Form Tactile Graphics", target = "_blank")
             # other videos on tactile graphics
             # https://www.youtube.com/watch?v=QeulfaWn_Ps
             # https://www.youtube.com/watch?v=IxiC7Papts4
    )
  )

}


