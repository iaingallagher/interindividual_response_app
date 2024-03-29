#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#    rsconnect::deployApp('Interindividual_Responses')

library(shiny)
library(plotly)
library(ggplot2)
theme_set(theme_bw())
source("interindividual_response_functions.R")

# Define UI for application that draws a histogram
ui <- navbarPage(
  
  #### MAIN PAGE ####
  title = "Statistics for Sports Science",
  sidebarLayout(
    
    sidebarPanel(
      img(src="swinton_2018.png", align = "center", width=200),
      p("Swinton, Paul A., Ben Stephens Hemingway, Bryan Saunders, Bruno Gualano, and Eimear Dolan. 2018. ‘A Statistical Framework to Interpret Individual Response to Intervention: Paving the Way for Personalized Nutrition and Exercise Prescription’. Frontiers in Nutrition 5. ",  a(href = "https://doi.org/10.3389/fnut.2018.00041", "https://doi.org/10.3389/fnut.2018.00041"),".")
    ),
 
  mainPanel(
    h1("Instructions"),
      p("This web app carries out calculations for typical error and generating confidence intervals for group and individual change scores as detailed in Swinton et al, 2018. There are three main components dealing with typical error, change scores and proportion of responders. The subcomponents associated with each of these are available through the tabs at the top of this page."),
      )
  ),
  
  #### TYPICAL ERROR COMPONENTS ####
  
  navbarMenu("Typical Error",
      
  #### 1 - INDIVIDUAL TE METHOD ####     
  
      tabPanel("Individual TE from multiple repeated measures (n>10)",
               
          sidebarLayout(
            sidebarPanel(
              # INSTRUCTIONS
              h4("Typical error for a procedure with n>10 tests on individual(s)."),
              p("This is a rare scenario but may be useful. Enter data below to calculate typical error from individual test-retest data."),
              p("Select a data file containing the test data. For a group this should be a comma-separated file with test occasions as rows and individuals in columns. For an individual this should be a a comma-separated file with a single column."),
              p("Enter the desired confidence level for the true score and press the Calculate TE button."),
              p("Example data is available ", a(href = 'https://github.com/iaingallagher/interindividual_response_app/blob/master/Interindividual_Responses/individual_TE_data.csv', 'here', .noWS = "outside"), '.', .noWS = c("after-begin", "before-end")),
              p("The confidence intervals from the individual TE are calculated using the t-distribution irrespective of the number of observations for each individual."),
              
              fileInput(inputId = "indiv_TE_data", label="Upload a data file", 
                        multiple = FALSE, placeholder = "No file selected", 
                        accept = "csv"),
              
              numericInput(inputId = "indiv_te_ci", label="CI Level", 
                           value=0.95, min=0.5, max=1, step=0.05),
              actionButton(inputId = "update_indiv_TE", label = "Calculate TE")
            ), # closes sidebarPanel
              
            mainPanel(
              h3("Results"),
              p("The table below shows the mean for each individual over all tests and the typical error estimated for each individual."),
              p("Two confidence values are shown for the TE. The moderated confidence interval takes account of the number of tests carried out on each individual whilst the unmoderated confidence interval is wider because it does not accont for the extra data collected for each individual through the repeated tests."),
              p("The data are plotted below the table."),
              tableOutput(outputId = "indiv_TE_table"),
              downloadButton("downloadData", "Download Table"),
                plotlyOutput(outputId = "indiv_TE_plot", width="50%", height="75%")
            ) # close mainPanel
          ) # close sidebarLayout
        ), # close tabPanel
      
  #### 2 - GROUP TEST RETEST DATA METHOD #### 
    tabPanel("Test Typical Error from group test retest data",
               
        sidebarLayout(
          sidebarPanel(
            # INSTRUCTIONS
            h4("Typical error from group test-retest data."),
            p("If you have data from individuals and each individual has completed a test and a re-test use this component to calculate typical error and a confidence interval for the individual scores."),
            p("Select a data file to upload. The file should be in comma-separated values (.csv) format."),
            p("Select the columns that represent the test and retest data."),
            p("Select the required confidence level for the true score and press the Calculate TE button."),
            p("Example data is available " , a(href = 'https://github.com/iaingallagher/interindividual_response_app/blob/master/Interindividual_Responses/orig_paper_data_only.csv', 'here', .noWS = "outside"), '.', .noWS = c("after-begin", "before-end")), 
            p("To reproduce the muscle carnitine example from the spreadsheet accompanying the paper load the example data and select MCARN_test as test and MCARN_restest as retest."),
            
            fileInput(inputId = "TE_data", label = "Upload a data file", multiple = FALSE, placeholder = "No file selected", accept = "csv"),
            selectInput(inputId = "test", label = "Test", choices = ""),
            selectInput(inputId = "retest", label = "Retest", choices = ""),
            numericInput(inputId = "te_ci", label="CI Level", value=0.95, min=0.5,max=1, step=0.05),
                   
            actionButton(inputId = "updateTE", label = "Calculate TE")
          ), # close sidebarPanel
                 
          mainPanel(
            h3("Results"),
            p("The results are shown in table form below."),
            tableOutput(outputId="TE_table"),
            
            p("The figure below shows the theoretical distribution of difference scores. This should be centered at zero and have a standard deviation equal to the TE multiplied by the square root of 2. See Swinton, 2018 (Sect 1.1) for details."),
            plotlyOutput(outputId = "TE_plot")
          ) 
        ) 
      ),# closes tabPanel for group test retest calculations

  #### 3 - TE FROM LITERATURE ####
      tabPanel("Typical error from a literature derived coefficient of variation with individual datapoint",
            
        sidebarLayout(
          sidebarPanel(
            
            h4("Typical error from a coefficient of variation."),
            p("Sometimes there are no data available to calculate typical error and thus a robust confidence interval around a single observed score. Coefficient of variation can be used instead. See section 1.2 of Swinton et al (2018) for details."),
            p("Enter a single observed score."),
            p("Enter a literature derived coefficient of variation."),
            p("Enter a desired confidence interval for the observed score and press the Calculate TE button."),
            p("To reproduce the example in section 1.2 of Swinton et al (2018) the CoV would be 4.94, the observed score would be 43.0 and the confidence level would be 0.75."),
            
            numericInput(inputId = "obs_score", label = "Obs Score", value = 0),
            numericInput(inputId = "cov", label = "Enter CoV", value = 0),
            numericInput(inputId = "lit_te_ci", label="CI Level", value=0.95, min=0.5,max=1, step=0.05),
            actionButton(inputId = "update_cov_TE", label = "Calculate TE")
          ),
            
          mainPanel(
            h3("Results"),
            tableOutput(outputId = "cov_TE_table")
            # ADD A PLOT WITH OBS SCORE AND CI
          ) 
        )
      ),
  
  #### 4 - TE FROM LITERATURE WITH GROUP DATA ####
      tabPanel("Typical error from a literature derived coefficient of variation with group data",
           
           sidebarLayout(
             sidebarPanel(
               
               h4("Typical error from a coefficient of variation with scores from a group."),
               p("Although not detailed explicitly in the paper confidence intervals for observed scores from a group can also be generated using a literature derived CoV (see the tab labelled 'SF-S6. TE from CV' in the spreadsheet accompanying Swinton et al (2018)."),
               p("Enter a file of values. This should be a comma-separated file with variables in columns."),
               p("Select the column of observed scores."),
               p(" Enter the literature derived CoV."),
               p("Enter a desired confidence interval for the observed scores."),
               p("To reproduce the example from the spreadsheet accompanying the paper load the example data and select CCT110_baseline as the test values, 4.94 as the typical error and choose a confidence level."),
               
               fileInput(inputId = "grp_TE_CV_data", label = "Upload a data file", multiple = FALSE, placeholder = "No file selected", accept = "csv"),
               selectInput(inputId = "grp_values", label = "Select test values", choices = NULL),
               numericInput(inputId = "grp_lit_cv", label="Enter CoV", value=0),
               numericInput(inputId = "grp_lit_ci", label="CI Level", value=0.95, min=0.5,max=1, step=0.05),
               actionButton(inputId = "grp_update_cov_TE", label = "Calculate TE")
             ),
             
             mainPanel(
               h3("Results"),
               tableOutput(outputId = "grp_cov_TE_table")
               # ADD A PLOT WITH SCORES AND CI
             ) 
           )
        )
    ),
  
  
  #### CHANGE SCORE COMPONENTS ####
  
  navbarMenu("Change Scores",
             
  #### 1 - SINGLE INDIVIDUAL CHANGE SCORE ####
             tabPanel("CI for Individual Change Score",
                      
                      h3("Individual Change Score with CI"),
                      sidebarLayout(
                        sidebarPanel(
                          
                          h3("CI for Individual Change Score"),
                          p("This component can be used to calculate confidence intervals around an observed score for a single individual."),
                          p("Enter the pre- and post-intervention scores."),
                          p("Enter the typical error for the procedure used."),
                          p("Enter the smallest worthwhile change (this is optional & will default to zero)."),
                          p("Enter the confidence level required."),
                          p("To reproduce the example from Swinton et al (2018) using muscle carnosine content enter 22.89 for the pre-score, 27.26 for post-score, 0.52 for typical error and 0.5 for desired confidence interval. These data are from subject 8 in the example file available " , a(href = 'https://github.com/iaingallagher/interindividual_response_app/blob/master/Interindividual_Responses/orig_paper_data_only.csv', 'here', .noWS = "outside"), '.', .noWS = c("after-begin", "before-end")),
                          
                          numericInput(inputId = "pre", label = "Pre Score", value = 0),
                          numericInput(inputId = "post", label = "Post Score", value = 0),
                          numericInput(inputId = "te", label = "Typical Error for Procedure", value = 0),
                          numericInput(inputId = "indiv_swc", label = "Desired SWC", value = 0),
                          numericInput(inputId = "ci", label="CI Level", value=0.95, min=0.5, max=1, step=0.05),
                          
                          actionButton(inputId = "update_indiv_CS", label = "Calculate")
                        ), 
                        
                        mainPanel(
                          
                          h3("Results"),
                          tableOutput(outputId="indiv_CS_table"),
                          plotlyOutput(outputId = "indiv_CS_plot")
                          
                        ) 
                      )  
             ),
             
             
  #### 2 - GROUP OF CHANGE SCORES ####
             tabPanel("CI for Several Individual Change Scores",
                      sidebarLayout(
                        sidebarPanel(
                          
                          h4("CI for Group Change Scores"),
                          p("This component can be used to calculate confidence intervals around observed scores for a group of individuals."),
                          p("Select a data file to upload. The file should be comma-separated values."),
                          p("Select the column that represents the subject identifiers."),
                          p("Select the columns containing the pre- and post-intervention scores."),
                          p("Enter the typical error for the procedure."),
                          p("Enter the smallest worthwhile change (this is optional & will default to zero)."),
                          p("Enter the desired confidence level."),
                          p("As an example to generate 90% confidence intervals for muscle carnosine pre- and post-intervention select the example file from ", a(href = 'https://github.com/iaingallagher/interindividual_response_app/blob/master/Interindividual_Responses/orig_paper_data_only.csv', 'here', .noWS = "outside"), '.', .noWS = c("after-begin", "before-end"), ", select the Participant column as subject ID, select the MCARN_baseline and MCARN_post variables as pre- and post-scores respectively, enter 0.52 as the typical error, leave the Desired SWC at 0 and enter 0.9 as the desired confidence level."),
 
                          # get the data file and other inputs
                          fileInput(inputId = "GRP_CS_data", label = "Upload a data file", multiple = FALSE, placeholder = "No file selected", accept = "csv"),
                          
                          selectInput(input = "id", label = "Indiv ID", choices = ""),
                          selectInput(inputId = "multiple_pre", label = "Pre", choices = ""),
                          selectInput(inputId = "multiple_post", label = "Post", choices = ""),
                          numericInput(inputId = "multiple_te", label="TE for Procedure", value=0),
                          numericInput(inputId = "swc", label = "Desired SWC", value = 0),
                          numericInput(inputId = "multiple_ci", label="Desired CI", value=0.95, min=0.5,max=1, step=0.05),
                          
                          actionButton(inputId = "update_group_CS", label = "Calculate")
                        ),
                        
                        # display table of change ci's & plot
                        mainPanel(
                          h3("Results"),
                          tableOutput(outputId="group_CS_table"),
                          downloadButton("downloadData_CS", "Download Table"),
                          plotlyOutput(outputId = "group_CS_plot")
                        )
                      )
             ),
             
  
  #### 3 - SMALLEST WORTHWHILE CHANGE ####
  
             tabPanel("Smallest Worthwhile Change",
                      
              sidebarLayout(
                sidebarPanel(
                  
                  h4("Smallest Worthwhile Change"),
                  p("This component will calculate the smallest worthwhile change (SWC) accounting for both the typical error and a desired effect size."),
                  p("Select a data file to upload. The file should be comma-separated values."),
                  p("Enter the desired effect size. This is optional & will default to zero."),
                  p("Enter the typical error for the procedure."),
                  p("To reproduce the CCT110 example from Swinton et al (2018) select the example ", a(href = 'https://github.com/iaingallagher/interindividual_response_app/blob/master/Interindividual_Responses/orig_paper_data_only.csv', 'data', .noWS = "outside"), ", select the CCT110_baseline in Select Variable box, enter 0.2 for the effect size and 2.2 for the typical error."),
                  
                  # read in file & enter vars, te & ci
                  fileInput(inputId = "SWC_data", label = "Upload a data file", multiple = FALSE, placeholder = "No file selected", accept = "csv"),
                  
                  selectInput(input = "swc_variable", label = "Select Variable", choices = ""),
                  numericInput(input = "eff_size", label = "Enter effect size for variable", value = 0),
                  numericInput(input = "swc_te", label = "Enter TE for procedure", value = 0),
                  
                  actionButton(inputId = "calc_swc", label = "Calculate SWC")
                ),
                
                mainPanel(
                  
                  h3("Results"),
                  tableOutput(outputId="SWC_table")
                )
              )
            ) # close tabPanel
  ),
  
  
  #### RESPONDER PROPORTION COMPONENTS ####
  
  navbarMenu("Proportion of Responders",  
             
  #### 1 - PROP RESPONDERS ####           
    tabPanel("Proportion of responders",
         
      sidebarLayout(
        sidebarPanel(
          
          h4("Intervention standard deviation"),
          p("This component will calculate a change in score variability due to an intervention. These calculations require data from control & intervention groups."),
          p("Select a data file to upload. The file should be comma-separated values and in long format. If you are unsure about the data structure please see the example data below."),
          p("Select the variables representing the pre- and post-intervention scores"),
          p("Select the variable indicating the group assignment."),
          p("Enter the labels for control & intervention groups."),
            p("To reproduce the example in the paper select the example ", a(href = "https://github.com/iaingallagher/interindividual_response_app/blob/master/Interindividual_Responses/orig_paper_data_only.csv", "data", .noWS = "outside") , ", MCARN_baseline as the pre-intervention scores, MCARN_post as the post-intervention scores, Group as the group indicator and finally enter the labels for each group (here B-A for intervention group and PLA for control group)."),
             
          # read in file & enter vars
          fileInput(inputId = "int_var_data", label = "Choose a file", multiple = FALSE, placeholder = "No file selected", accept = "csv"),
             
          selectInput(input = "pre_variable", label = "Select pre intervention scores", choices = NULL),
          selectInput(input = "post_variable", label = "Select post intervention scores", choices = NULL),
          selectInput(input = "grouping_variable", label = "Select grouping variable", choices = NULL),
          selectInput(input = "ctrl_ind", label = "Control group label", choices = NULL), 
          selectInput(input = "int_ind", label = "Intervention group label", choices = NULL),
          numericInput(input = "prop_resp_eff_sz", label = "Effect Size", value = 0),
          selectInput(input = "direction", label = "Enter direction for proportion (above/below SWC)", choices = c("Above", "Below"), selected = "Above"),
          numericInput(input = "boot_ci", label = "Enter desired CI for bootstrap estimate", value = 0.95),
          numericInput(input = "boot_iters", label = "Iterations for bootstrap", value = 1000),
             
          actionButton(inputId = "calcs", label = "Calculate")
        ),
           
        mainPanel(
             
          h3("Results"),
          p("Variability due to intervention"),
          tableOutput(outputId="Prop_resp_data"),
          # plot
          plotlyOutput(outputId = "prop_resp_plot"),
          # bootstrapped propoertion CI
          p(),
          p("Bootstrapped CI for responder proportion"),
          p("Bootstrapping is a random technique so the mean bootstrapped proportion may not match the proportion of responders in your data."),
          tableOutput(outputId="boot_ci"),
          # plot
          plotlyOutput(outputId = "boot_ci_plot")
        )
      )
    ),
  
    
  #### 2 - RESPONDER PROPORTION ####
    tabPanel("Responder Proportion",
      sidebarLayout(
        sidebarPanel(
          
          # INSTRUCTIONS
          h4("Responder proportion"),
          p("This component will calculate the proportion of responders according to whether the confidence interval for an observed score overlaps with a defined smallest worthwhile change."),
          p("Enter the observed change over the group."),
          p("Enter the intervention standard deviation (as calculated in e.g. the Intervention standard deviation tab)."),
          p("Enter the desired effect size for a SWC calculation."),
          p("Enter the direction of the expected effect compared to the SWC."),
          p("To reproduce the example in the paper enter 10.2 as the mean change score for the intervention, 5.07 as the standard deviation due to the intervention, a desired efect size of 0.2 and leave the direction for proportion set at 'Above'."),
          
          # get required vars; prob from INTERVENTION SD above
          numericInput(input = "int_cs_mn", label = "Enter mean change score for intervention", value = 0, step = 0.1),
          numericInput(input = "int_sd", label = "Enter standard deviation due to intervention", value = 0, step = 0.1),
          numericInput(input = "prop_swc_cutoff", label = "Enter desired effect size for SWC calculation", value = 0, step=0.1),
          # selectInput(input = "direction", label = "Enter direction for proportion (above/below SWC)", choices = c("Above", "Below"), selected = "Above"),
          
          actionButton(inputId = "calc_prop_resp", label = "Calculate")
          
        ),
          
        mainPanel(
          h3("Results"),
          # table
          p("Proportion of Responders"),
          tableOutput(outputId="prop_resp_table"),
          # plot
          # plotlyOutput(outputId = "boot_CI_prop_plot")
            
        )
      )
    )
  )
)
    

#### END UI PART #### 

# SERVER LOGIC ####

server <- function(input, output, session) {
  
  # EXAMPLE DATA
  
  # INDIV TE #####
  indiv_TE_reactive <- reactive({
    inFile <- input$indiv_TE_data
    req(inFile) # require an input to run
    read.csv(inFile$datapath)
  }) # closes reactive
  
    # on update button
    observeEvent(input$update_indiv_TE, {
      
    if(!is.null(input$indiv_TE_data)){
      
      df <- read.csv(input$indiv_TE_data$datapath, header = TRUE, sep = ",") # dataframe in
      var <- input$indiv_te_ci # user chosen CI
      
      indiv_TEResult <- indiv_te_t(df=df, ci=var) # apply function

      # Table
      if(nrow(df) == 1){
        output$indiv_TE_table <- renderText("Cannot calculate TE with one observation.")
      }
      else{
        output$indiv_TE_table <- renderTable(indiv_TEResult, rownames = FALSE)
      
        # download data
        output$downloadData <- downloadHandler(
          filename = "indiv_TEResult.csv",
          content = function(file){
            write.csv(indiv_TEResult, file, row.names=FALSE) })
      
        # Plot
        indiv_te_plot <- ggplot() + geom_pointrange(data=indiv_TEResult, aes(x=ID, y=`Indiv Test Means`, ymin=`Lower CI Limit`, ymax=`Upper CI Limit`), alpha=0.2, size=1) + scale_x_discrete(limits=indiv_TEResult$ID)
      
        indiv_te_plot <- indiv_te_plot + geom_pointrange(data=indiv_TEResult, aes(x=`ID`, y=`Indiv Test Means`, ymin=`Moderated Lower CI Limit`, ymax=`Moderated Upper CI Limit`), colour='chocolate', size=1.2)
      
        indiv_te_plot <- indiv_te_plot + coord_flip()
       
        # output as plotly
        output$indiv_TE_plot <- renderPlotly(indiv_te_plot)
         } # closes if n == 1
      } # closes if file loaded
      
    }) # closes observeEvent

  
    
    
  # TEST-RETEST TE ####
  # get data
  TE_reactive <- reactive({
    inFile <- input$TE_data
    req(inFile) # require an input to run
    read.csv(inFile$datapath)
  })
  
  # get variables into R session
  observe({
    updateSelectInput(session, "test", choices = names(TE_reactive()))
    updateSelectInput(session, "retest", choices = names(TE_reactive()))
  })
  
  # on update button
  observeEvent(input$updateTE, {
    if(!is.null(input$TE_data)){
      
      df <- read.csv(input$TE_data$datapath, header = TRUE, sep = ",")
      var1 <- df[, which(colnames(df) == input$test)]
      var2 <- df[, which(colnames(df) == input$retest)]
      var3 <- input$te_ci
      
      # dat <- data.frame(var1 = test, var2 = retest)
      TEResult <- TE(t1 = var1, t2 = var2, ci=var3)
      
      # Table
      output$TE_table <- renderTable(TEResult, rownames = TRUE)
      
      # Plot
      x <- seq(from = -3*TEResult[,2], to= 3*TEResult[,2], by = 0.1) # generate potential diff scores
      y <- dnorm(x, 0, sd = TEResult[,2])
      # create plot ASSUMING ZERO MEAN
      density_df <- data.frame(x=x, y=y)
      # plot
      dens_p <- ggplot(density_df, aes(x=x, y=y)) + geom_line()
    
      # plot of normally distributed difference scores
      dens_p <- dens_p + labs(title="Distribution of difference scores", x="", y="")
      dens_p <- ggplotly(dens_p)
      output$TE_plot <- renderPlotly(dens_p)
    }
  }) # close observe event
  
  
  
  
  
  # SINGLE COV TE ####
  
  # on update button
  observeEvent(input$update_cov_TE,{
    var1 <- input$cov
    var2 <- input$obs_score
    var3 <- input$lit_te_ci
    cov_TEResult <- cov_te(cv=var1, os=var2, ci=var3)
    
    output$cov_TE_table <- renderTable(cov_TEResult, rownames = FALSE)
  })
  
  # GROUP COV TE ####
  # get data
  GRP_CV_reactive <- reactive({
    inFile <- input$grp_TE_CV_data
    req(inFile) # require an input to run
    read.csv(inFile$datapath)
  })
  
  # get variables into R session
  observe({
    updateSelectInput(session, "grp_values", choices = names(GRP_CV_reactive()))
  })
  
  # generate output
  observeEvent(input$grp_update_cov_TE, {
    if(!is.null(input$grp_TE_CV_data)){
      
      df <- read.csv(input$grp_TE_CV_data$datapath, header = TRUE, sep = ",")
      baseline_vals <- df[, which(colnames(df) == input$grp_values)]
      
      grp_cov_TEResult <- grp_cov_te(input$grp_lit_cv, baseline_vals, input$grp_lit_ci)
      output$grp_cov_TE_table <- renderTable(grp_cov_TEResult, rownames = FALSE)
      
    }
  })
  
  
  # INDIV CHANGE SCORES ####
    observeEvent(input$update_indiv_CS, {
      
      # create dataframe to display
      pre <- input$pre
      post <- input$post
      te <- input$te
      ci <- input$ci
      
      indiv_cs_data <- cs_ci(pre = pre, post = post, te = te, ci = ci)
      output$indiv_CS_table <- renderTable(indiv_cs_data)
      
      # if swc is zero plot a line at zero
      if(input$indiv_swc == 0){
     
      # create plot
      ci_val <- ci * 100
      ax_lab <- paste("Mean Difference +/- ", ci_val, "% CI", sep = "")
     
      indiv_cs_plot <- ggplot() + geom_pointrange(data = indiv_cs_data, aes(x = 1, y = Change, ymin=`Lower CI Limit`, ymax=`Upper CI Limit`), colour='chocolate', size=1.2) + theme(axis.ticks = element_blank(), axis.text.y = element_blank())
      indiv_cs_plot <- indiv_cs_plot + labs (x = "", y = ax_lab) + geom_hline(yintercept = 0, colour = "cadetblue", size = 1, linetype = "dashed", alpha = 0.5) + coord_flip()
     
      output$indiv_CS_plot <- renderPlotly(indiv_cs_plot)
      }
      
      # if swc != 0 plot a line at swc & zero
      else{
        
        # create plot
        ci_val <- ci * 100
        ax_lab <- paste("Mean Difference +/- ", ci_val, "% CI", sep = "")
        
        indiv_cs_plot <- ggplot() + geom_pointrange(data = indiv_cs_data, aes(x = 1, y = Change, ymin=`Lower CI Limit`, ymax=`Upper CI Limit`), colour='chocolate', size=1.2) + theme(axis.ticks = element_blank(), axis.text.y = element_blank())
        indiv_cs_plot <- indiv_cs_plot + labs (x = "", y = ax_lab) + geom_hline(yintercept = c(0,input$indiv_swc), colour = "cadetblue", size = 1, linetype = "dashed", alpha = 0.5) + coord_flip()
        
        output$indiv_CS_plot <- renderPlotly(indiv_cs_plot)
        
      }
   }) # close observe event
  
  
  

  # GROUP OF CHANGE SCORES ####
  
  # get the group data
  GRP_CS_reactive <- reactive({
    inFile <- input$GRP_CS_data
    req(inFile) # require an input to run
    read.csv(inFile$datapath)
  })
  
  # get pre & post scores
  observe({
    updateSelectInput(session, "id", choices = names(GRP_CS_reactive()))
    updateSelectInput(session, "multiple_pre", choices = names(GRP_CS_reactive()))
    updateSelectInput(session, "multiple_post", choices = names(GRP_CS_reactive()))
  })
  
  # on update button
  observeEvent(input$update_group_CS, {
    if(!is.null(input$GRP_CS_data)){
      
      df <- read.csv(input$GRP_CS_data$datapath, header = TRUE, sep = ",")
      ids <- df[, which(colnames(df) == input$id)]
      ids <- paste('Subject:', ids, sep = ' ')
      pre <- df[, which(colnames(df) == input$multiple_pre)]
      post <- df[, which(colnames(df) == input$multiple_post)]
      te <- input$multiple_te
      ci <- input$multiple_ci
      
      CSResult <- cs_ci(pre, post, te, ci)
      CSResult <- cbind(ids, CSResult) # add subj ids
      colnames(CSResult)[1] <- 'ID'
      # Table for output
      output$group_CS_table <- renderTable(CSResult)
      
      # download data
      output$downloadData_CS <- downloadHandler(
        filename = "Group_Change_Score_Result.csv",
        content = function(file){
          write.csv(CSResult, file, row.names=FALSE) })
      
      
      # Plot
      if(input$swc == 0){
        group_CS_plot <- ggplot() + geom_pointrange(data = CSResult, aes(x = ids, y=`Change`, ymin=`Lower CI Limit`, ymax=`Upper CI Limit`), size=2, colour = "chocolate2") # basic plot
        group_CS_plot <- group_CS_plot + scale_x_discrete(limits = CSResult$ID) # subj labels
        group_CS_plot <- group_CS_plot + geom_hline(yintercept = 0, colour = "cadetblue", size = 1, linetype = "dashed", alpha = 0.5) + coord_flip() # swc and flip axes
        output$group_CS_plot <- renderPlotly(group_CS_plot)
      }
      
      else{
        group_CS_plot <- ggplot() + geom_pointrange(data = CSResult, aes(x = ids, y=`Change`, ymin=`Lower CI Limit`, ymax=`Upper CI Limit`), size=2, colour = "chocolate2") # basic plot
        group_CS_plot <- group_CS_plot + scale_x_discrete(limits = CSResult$ID) # subj labels
        group_CS_plot <- group_CS_plot + geom_hline(yintercept = c(0, input$swc), colour = "cadetblue", size = 1, linetype = "dashed", alpha = 0.5) + coord_flip() # swc and flip axes
        output$group_CS_plot <- renderPlotly(group_CS_plot)
      }
      
    } # closes if statement for data
  }) # close observe event
  
  
  # SWC ####
  # get the file path
  SWC_reactive <- reactive({
    inFile <- input$SWC_data
    if (is.null(inFile))
      return(NULL)
    read.csv(inFile$datapath)
  })
  
  # get variable for SWC calc
  observe({
    updateSelectInput(session, "swc_variable", choices = names(SWC_reactive()))
  })
  
  # carry out the calculation & return data
  observeEvent(input$calc_swc, {
    # get data for calculation
    df <- read.csv(input$SWC_data$datapath, header = TRUE, sep = ",")
    input_var <- df[, which(colnames(df) == input$swc_variable)]
    
    # calculation & output
      var_sd <- sd(input_var)
      eff_size = input$eff_size
      te <- input$swc_te
      swc <- (var_sd * eff_size) + te
      
      swc_data <- data.frame(`Baseline SD` = var_sd, `Effect Size` = eff_size, `TE` = te, `SWC` = swc)
      output$SWC_table <- renderTable(swc_data)
  }
  )
  
  
  
  
  
  
  # PROPORTION OF RESPONDERS ####
  # get the file path
  PR_reactive <- reactive({
    inFile <- input$int_var_data
    req(inFile) # require an input to run
    read.csv(inFile$datapath)
  })
  
  # get variables
  get_vars <- observe({
    updateSelectInput(session, "pre_variable", choices = names(PR_reactive()))
    updateSelectInput(session, "post_variable", choices = names(PR_reactive()))
    updateSelectInput(session, "grouping_variable", choices = names(PR_reactive()))
  })
  
  # populate group choice boxes
  observeEvent(input$grouping_variable, {
    column_levels <- as.character(sort(unique(PR_reactive()[,input$grouping_variable])))
    updateSelectInput(session, "ctrl_ind", choices = column_levels)
    updateSelectInput(session, "int_ind", choices = column_levels)
  })
  
  # carry out the calculations for intervention sd, prop resp above swc and bootstrap CI & return data
  observeEvent(input$calcs, {
    # get data for calculation
    df <- read.csv(input$int_var_data$datapath, header = TRUE, sep = ",")
    
    # calculate intervention sd, needed for prop_resp function that runs second here
    int_data <- int_sd(df, input$pre_variable, input$post_variable, input$grouping_variable, input$ctrl_ind, input$int_ind)
    # calculate prop responders
    prop_responders_data <- prop_resp(int_data$int_mean_diff, int_data$intervention_sd, input$prop_resp_eff_sz, input$direction)
    # bootstrap CI for prop responders
    boot_prop_CI <- prop_ci_bootstrap(df, input$pre_variable, input$post_variable, input$grouping_variable, input$ctrl_ind, input$int_ind, input$prop_resp_eff_sz, input$direction, input$boot_ci, input$boot_iters)
    
    # render output
    # prop_resp_output_data <- as.data.frame(int_data$int_mean_diff, int_data$intervention_sd, prop_responders$prop_responders)
    output$Prop_resp_data <- renderTable(prop_responders_data)
    output$boot_ci <- renderTable(boot_prop_CI)
    
    ## Plot for proportion of responders ## 
    cs_mn <- prop_responders_data[,1]
    intervntn_sd <- prop_responders_data[,2]
    prop <- prop_responders_data[,3]
    x <- seq(from = cs_mn-(3*intervntn_sd), to = cs_mn+(3*intervntn_sd), by = 0.1) # generate change scores
    y <- dnorm(x,cs_mn,intervntn_sd)

    # create plot
    density_df <- data.frame(x=x, y=y)

    # quantile cutoff
    if(input$direction == 'Above'){
      prop <- quantile(density_df$x, probs = 1-prop) # cutoff for plot
    }
    else{
      prop <- quantile(density_df$x, probs = prop) # cutoff for plot
    }

    # plot
    prop_plot <- ggplot(density_df, aes(x=x, y=y)) + geom_line() # plot of normally distributed scores
    if(input$direction == 'Above'){
      prop_plot <- prop_plot + geom_area(data = subset(density_df, x >= prop), fill = 'cadetblue', alpha = 0.5) # shade above
    }

    else{
      prop_plot <- prop_plot + geom_area(data = subset(density_df, x <= prop), fill = 'cadetblue', alpha = 0.5) # shade below
    }

    prop_plot <- prop_plot + labs(title="Distribution of possible change scores")
    prop_plot <- ggplotly(prop_plot)
    output$prop_resp_plot <- renderPlotly(prop_plot)
    
    # create plot for bootstrapped prop responder CI
    ax_lab = paste("Proportion of responders with bootstrapped ", input$boot_ci*100, "% CI", sep="")
    boot_ci_plot <- ggplot() + geom_pointrange(data = boot_prop_CI, aes(x = 1, y = prop_mn, ymin = ci_lower, ymax = ci_upper), colour='chocolate', size=1.2) + theme(axis.ticks = element_blank(), axis.text.y = element_blank())
    
    boot_ci_plot <- boot_ci_plot + labs (x = "", y = ax_lab) + coord_flip()
    
    output$boot_ci_plot <- renderPlotly(boot_ci_plot)
    
    
  }) # end long observeEvent section

} # close server block

# Run the application 
shinyApp(ui = ui, server = server)