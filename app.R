library(dplyr)
library(shiny)
# library(shinycssloaders)

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
                        # wellPanel(withSpinner(uiOutput(outputId = "image")),
                            br(),
                            radioButtons('choice','What is the best description:', choices = list('none selected'='none'), inline = F, selected = 'none'),
                            # br(),
                        textOutput(outputId = "textR"),

                        br(),
                        verbatimTextOutput(outputId = "Feedback"),
                        
                        actionButton("Reset", label="Reset score"),
                        br(),
                         ) #Close wellPanel
                      ), #Close absolutePanel

            ),     #Close tabPanel
            tabPanel("Settings",
                     br(),
                     radioButtons(inputId = 'imageSelection',label='Select type of Images', choices = list('Cells'='Cells', 'Smileys'='faces', 'Flags'='flags'), inline = F, selected = 'Cells'),
                     numericInput(inputId = 'n_answers', label='number of answers', value =4, min = 2, max = 10, step = 1),
                     hr(),
                     h4('Image Credits:'),
                     conditionalPanel(
                       condition = "input.imageSelection=='cells'",p('Fluorescence images from the "GFP-cDNA Localisation Project": http://gfp-cdna.embl.de'),hr()),              
                     conditionalPanel(
                       condition = "input.imageSelection!='cells'",p('Pictures from OpenMoji - the open-source emoji and icon project: https://openmoji.org'),hr()),
                     
                     
                     
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
  
      imageSelection.selected <<- input$imageSelection
      
      #Read the names of subdirectories with images, these will used to generate a list with choices
      dirlist <-  list.files(path = './www/',include.dirs = T)
      updateRadioButtons(session, "imageSelection", choices = as.character(dirlist), inline = F, selected = imageSelection.selected)
      
      choices <- generate_answers(filelist(), n, input$n_answers)
      updateRadioButtons(session, "choice", choices = as.character(choices), inline = F, selected = 'none')
})
    
# Read list of files with images
filelist <- reactive ({
        subdir <- input$imageSelection
        filelist <-   list.files(path = paste0('./www/',subdir), pattern="*.png|*.jpg|*.jpeg|*.gif")
        n <<-  ceiling(runif(1, min=0, max=length(filelist))) 
        # observe({print(filelist)})
        return(filelist)
    })

# Function that generates a list of randomized answers, consisting of 1 correct and several incorrect answers
generate_answers <- function(filelist, n, number_of_choices=4)  {
     files_noext <- gsub(filelist, pattern="\\..*", replacement="")
     answers <- gsub(files_noext, pattern="_.*", replacement="")
     #global update of the correct answer
     correct_answer <<- answers[n]
     observe({print(paste0('generate answers:',correct_answer))})
     unique_answers <- unique(answers)
     if (number_of_choices < 2) {number_of_choices <- 2}
     if (number_of_choices > length(unique_answers)) {number_of_choices <- length(unique_answers)}

     wrong_answers <- unique_answers[unique_answers!=correct_answer]
     choices <- sample(c(sample(wrong_answers,(number_of_choices-1)),correct_answer),number_of_choices)
     choices <- c(choices,'none')
     return(choices)
 }

# Display the image and display a new one if correctly answered
output$image<-renderUI({
    if (input$choice == correct_answer) {
      n_correct <<- n_correct +1
      tot <<- tot +1
      n <<-  ceiling(runif(1, min=0, max=length(filelist())))
      choices <- generate_answers(filelist(), n, input$n_answers)
      updateRadioButtons(session, "choice", choices = as.character(choices), inline = F, selected = 'none')
      img(src=paste0(input$imageSelection,'/',filelist()[n]), width = '300px')
    } else if (input$choice != correct_answer && input$choice != 'none') {
      tot <<- tot +1
      showNotification(
        sample(c('Try again', 'Perseverance will pay off!', 'Nope...', 'Keep trying','Grab another coffee', 'Consider googling', 'Close, but not correct', 'Incorrect','Have another look',"Don't quit", "I don't think so"),1),
        duration = 1, 
        closeButton = F,
        type = sample(c("default", "message", "warning", "error"),1))
      img(src=paste0(input$imageSelection,'/',filelist()[n]), width = '300px')
    } else if (input$choice != correct_answer && input$choice == 'none') {
    img(src=paste0(input$imageSelection,'/',filelist()[n]), width = '300px')
    }
})

# Display feedback
# output$Feedback <- renderText({
#   if (input$choice !=correct_answer && input$choice !='none') {
#     text <- sample(c('Try again!', 'Perseverance will pay off!','Nope...', 'Keep trying!','Grab another coffee', 'Consider googling', 'Close, but not correct', 'Incorrect','Have another look',"Don't quit!", "I don't think so"),1)
#   }
# })

# Display the score
output$textR <- renderText({
  # observe({print(paste('Choice vs truth:',input$choice,correct_answer))})
    input$choice
    input$Reset
    text <- paste0('Correct: ',n_correct,'/',round(tot),' = ',round(n_correct/tot*100),'%')
})

# Reset the score
observeEvent(input$Reset, {
  n_correct <<- 0
  tot <<- 0.001
})


} # Close server

# Run the application 
shinyApp(ui = ui, server = server)

