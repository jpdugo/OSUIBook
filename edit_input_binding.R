# OSUICode::run_example(
#  "input-system/edit-binding-client",
#   package = "OSUICode"
# )

# picking a single date will be treated as if a range with the same start and end date was selected

box::use(
  shiny[...],
  shinyWidgets[...],
  stringr[str_c],
  shinyjs[...],
  lubridate[now, days]
)

# Define UI for application
ui <- fluidPage(
  shinyjs::useShinyjs(),
  titlePanel("Air Date Picker Input Example"),
  sidebarLayout(
    sidebarPanel(
      airDatepickerInput(
        inputId = "date",
        label = "Select a date:",
        placeholder = "Select a date",
        clearButton = TRUE,
        range = TRUE
      ),
      actionButton(
        inputId = "calculate",
        label = "Calculate"
      )
    ),
    mainPanel(
      textOutput("selected_date")
    )
  )
)

# Define server logic
server <- function(input, output) {
  output$selected_date <- renderText({
    result()
  })

  result <- eventReactive(input$calculate, {
    paste("You have selected:", input$date)
  })

  observe({
    req(input$date)
    js <- str_c(
      'Shiny.unbindAll();
       var airDateBinding = Shiny
       .inputBindings
       .bindingNames["shinyWidgets.AirDatepicker"]
       .binding;
       $.extend(airDateBinding, {
         getValue: el => {
         var dp = airDateBinding.store[el.id];
         var sd = dp.selectedDates;
         var timepicker = $(el).attr("data-timepicker");
         var res;
         if (typeof sd != "undefined" && sd.length > 0) {
           res = sd.map(function(e) {
             console.log(e);
             //return dayjs(e).format(); figure out how to get this to work
             return e;
           });

         if (res.length === 1) {
            res = [res[0], res[0]];
         }
         return res;
         } else {
           return null;
         }
       }
      });
      Shiny.bindAll();'
    )

    shinyjs::runjs(js)
  })
}

shinyApp(ui = ui, server = server)
