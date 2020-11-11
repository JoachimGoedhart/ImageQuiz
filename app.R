# library(magick)
library(dplyr)
library(shiny)

# All emojis designed by OpenMoji – the open-source emoji and icon project. License: CC BY-SA 4.0
# https://openmoji.org


# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(
      HTML(".shiny-notification {
             position:fixed;
             top: 190px;
             left: 100px;
             font-size: 20px;
             }
             "
      )
    )
  ),
    # Application title
    titlePanel("ImageQuiz"),

    mainPanel(
        tabsetPanel(
            tabPanel("Quiz",

                    absolutePanel(top = 60, left = 20, width = 350, draggable = F,
                        wellPanel(uiOutput(outputId = "image"),
                            br(),
                            radioButtons('choice','Choose the word that matches the best with the image', choices = list('A'), inline = F, selected = 'A'),
                            actionButton("Submit", label="Submit Answer"),
                            br(),
                            br(),
                            textOutput(outputId = "textR")
                         ) #Close wellPanel
                      ), #Close absolutePanel

            ),     #Close tabPanel
            tabPanel("Settings",
                     br(),
                     radioButtons(inputId = 'imageSelection',label='Select type of Images', choices = list('Cells'='cells', 'Smileys'='faces', 'Flags'='flags'), inline = F, selected = 'cells'),
                     numericInput(inputId = 'n_answers', label='number of answers', value =4, min = 1, max = 10, step = 1),
                     actionButton("Reset", label="Reset score"),
                     NULL
            ),     #Close tabPanel
            tabPanel("About", includeHTML("about.html")
            ) #Close tabPanel

        ) #Close tabsetPanel()
    ) # Close mainPanel
)


server <- function(session, input, output) {
  
#Initialize variables
n <- 0
n_correct <- 0
tot <- 0.001
    
# Necessary for correct initialization
observe({
      req(input$n_answers)
      choices <- generate_answers(filelist(), n, input$n_answers)
      updateRadioButtons(session, "choice", choices = as.character(choices), inline = F, selected = character(0))
})
    
# Read list of files with images
filelist <- reactive ({
        subdir <- input$imageSelection
        filelist <-   list.files(path = paste0('./www/',subdir), pattern="*.png|*.jpg|*.jpeg|*.gif")
        n <<-  ceiling(runif(1, min=0, max=length(filelist))) 
        observe({print(filelist)})
        return(filelist)
    })
      
# Activated when answer is submitted
observeEvent(input$Submit, {
        # When correctly answered, randomly select a new image with possible answers
        if (input$choice == correct_answer) {
            n <<-  ceiling(runif(1, min=0, max=length(filelist())))
            choices <- generate_answers(filelist(), n, input$n_answers)
            updateRadioButtons(session, "choice", choices = as.character(choices), inline = F, selected = character(0))
            observe({print("correct")})
            n_correct <<- n_correct +1
            tot <<- tot +1
        # When incorrect, notify and wait for the next answer
        } else if (input$choice != correct_answer){
            observe({print("incorrect")})
            tot <<- tot +1
            showNotification(
              sample(c('Try again', 'Nope', 'Keep trying','Grab another coffee', 'Keep trying', 'Consider google', 'Close, but not correct', 'Incorrect','Have another look',"Don't quit", "I don't think so"),1),
              duration = 1, 
              closeButton = F,
              type = sample(c("default", "message", "warning", "error"),1))
        }
    })

# Function that generates a list of possible answers, consisting of 1 correct and several incorrect answers
generate_answers <- function(filelist, n, number_of_choices=4)  {
     files_noext <- gsub(filelist, pattern="\\..*", replacement="")
     answers <- gsub(files_noext, pattern="_.*", replacement="")
     #global update of the correct answer
     correct_answer <<- answers[n]
     unique_answers <- unique(answers)
     if (number_of_choices < 2) {number_of_choices <- 2}
     if (number_of_choices > length(unique_answers)) {number_of_choices <- length(unique_answers)}

     wrong_answers <- unique_answers[unique_answers!=correct_answer]
     choices <- sample(c(sample(wrong_answers,(number_of_choices-1)),correct_answer),number_of_choices)
     return(choices)
 }

# Display the image 
output$image<-renderUI({
    input$Submit
    img(src=paste0(input$imageSelection,'/',filelist()[n]), width = '300px')
})

# Display the score
output$textR <- renderText({
    input$Submit
    input$Reset
    paste0('Correct: ',n_correct,'/',round(tot),' = ',round(n_correct/tot*100),'%')
})

observeEvent(input$Reset, {
  n_correct <<- 0
  tot <<- 0.001
})


} # Close server

# Run the application 
shinyApp(ui = ui, server = server)

