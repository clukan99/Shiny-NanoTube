library(shinyBS)
library(shinyjs)
library(Biobase)
library(limma)
library(plotly)
library(ggplot2)
library(DT)
library(NanoTube)
library(qusage)

source("helpers.R")
##Add gradient scroll 
##Add sticky header on scroll
#Add something interactive where person can see the files after they are uploaded
shinyUI(fluidPage(id="formatting", theme = shinythemes::shinytheme("simplex"),
                  
                  navbarPage(div(img(src="NanoTube-Logo.png", 
                                     style="float:right", height = 40, width = 110), ""),
                             tags$head(
                               tags$style(HTML('.navbar-nav > li > a, .navbar-brand {
                            padding-top:4px !important; 
                            padding-bottom:4px !important;
                            line-height: 40px !important;
                            height: 40px;
                            font-size: 15px;
                            }
                           .navbar {min-height:50px !important;}'))),
                             selected = "Job Setup",
                             id = "master",
                             ####
                             #includeScript(),
                             useShinyjs(),
                             ##CSS here    
                             tags$head(
                               tags$link(rel = "stylesheet", type = "text/css", href = "styling.css")
                             ),
                             tags$style(type="text/css", "body {padding-top: 70px;}"),
                             
                             tabPanel("Job Setup",
                                      
                                      fluidPage(
                                        
                                        h2("Data Entry"),
                                        
                                        fluidRow(
                                          ######################
                                          column(12,
                                                 fileInput("expr",
                                                           label = "NanoString data",
                                                           multiple = FALSE),
                                                 bsTooltip("expr",
                                                           "Either a folder containing .RCC files, or an expression matrix in a .csv or .txt file.",
                                                           placement = "bottom", trigger = "hover", options = NULL)
                                          ),
                                       
                                          
                                          
                                          ######################
                                        ),
                                        fluidRow(
                                          column(4,
                                                 fileInput("phen",
                                                           label = "Sample group classifiers",
                                                           multiple = FALSE),
                                                 bsTooltip("phen",
                                                           "This file should contain a group classifier for each sample, in the same order as in the expression dataset. If not provided, groups will be interpreted from sample file names (see Help).",
                                                           placement = "bottom", trigger = "hover", options = NULL)
                                          )
                                        ),
                                        fluidRow(
                                          column(4,
                                                 textInput("basePhen",
                                                           label = "Base group",
                                                           value = ""),
                                                 bsTooltip("basePhen", 
                                                           "The group against which other groups will be compared, or the denominator of your Fold Change (such as the Control group). If empty, the first group will be used.",
                                                           placement = "bottom", trigger = "hover", options = NULL)
                                          )
                                          
                                          
                                        ),
                                        
                                        fileInput("gsDb",
                                                  label = "Gene set database (Optional)",
                                                  multiple = FALSE),
                                        
                                        bsTooltip("gsDb",
                                                  "A gene set database file, either in .gmt format or an .rds file containing an R-format list of gene sets",
                                                  placement = "bottom", trigger = "hover", options = NULL),
                                        
                                        actionButton("run",
                                                     label = "Analyze Data"),
                                        #submitButton("Analyze Data"),
                                        
                                        br(), br(),
                                        
                                        actionLink("adv", "Advanced Options"),
                                        
                                        h4("Normalization Options", id = "normTxt"),
                                        
                                        textInput("hk",
                                                  label = "Housekeeping Genes",
                                                  value = ""),
                                        bsTooltip("hk",
                                                  "Optional: A list of housekeeping genes present in the input data, separated by commas. If not provided, housekeeping genes will be identified as marked in the input file."),
                                        
                                        numericInput("bgP",
                                                     label = "Negative Control Threshold (t test p-value)",
                                                     value = 0.05,
                                                     min = 0.00001,
                                                     max = 2),
                                        bsTooltip("bgP",
                                                  "Expression threshold (vs. negative control genes) for inclusion, in the form of a p-value from a 2-sample t test (see Help). To include all genes in analysis, set to 2."),
                                        
                                        h4("Gene Set Analysis Options", id = "gseaTxt"),
                                        
                                        numericInput("minSize",
                                                     label = "Min size (exclude smaller sets)",
                                                     value = 5,
                                                     min = 0,
                                                     max = 500),
                                        bsTooltip("minSize",
                                                  "Minimum size of gene sets for inclusion in pathway analysis (only genes included in NanoString data are counted)."),
                                        
                                        
                                      )),
                             
                             tabPanel("QC Results",
                                      navbarPage("QC", id = "qc",
                                                 tabPanel("Positive Controls",
                                                          fluidPage(
                                                            fluidRow(
                                                              column(8,
                                                                     plotOutput("posPlot", width = "100%")
                                                              ),
                                                              
                                                              column(4,
                                                                     tableOutput("posTab")
                                                              )))),
                                                 
                                                 tabPanel("Negative Controls",
                                                          fluidPage(
                                                            tableOutput("negTab"),
                                                            
                                                            plotlyOutput("negPlot")
                                                          )),
                                                 
                                                 tabPanel("Housekeeping",
                                                          fluidPage(
                                                            fluidRow(
                                                              column(8,
                                                                     plotlyOutput("hkPlot1", width = "100%"),
                                                                     br(),br(),
                                                                     plotlyOutput("hkPlot2", width = "100%")
                                                              ),
                                                              
                                                              column(4,
                                                                     tableOutput("hkTab")
                                                              ))))
                                      )
                                      
                             ),
                             
                             tabPanel("Analysis Results",
                                      navbarPage("Analysis", id = "de",
                                                 tabPanel("PCA",
                                                          fluidPage(
                                                            plotlyOutput("pcaPlot")
                                                          )
                                                 ),
                                                 
                                                 #####
                                                 tabPanel("Volcano",
                                                          fluidPage(
                                                            h4("Volcano Plot"),
                                                            ####
                                                            numericInput('volcanoVertLineInput','log2(FC)', value = 0, min = 0, max = 4),
                                                            numericInput('volcanoHorLineInput','-log10(p)', value = 0, min = 0, max = 4),
                                                          
                                                            plotlyOutput("canoPlot"),
                                                            #plotOutput("canoPlot")
                                                          )
                                                          
                                                 ),
                                                 #######
                                                 tabPanel("Differential Expression",
                                                          fluidPage(
                                                            h4("Differentially expressed genes (q < 0.05)"),
                                                            tableOutput("deCounts"),
                                                            
                                                            h4("Full Results"),
                                                            DTOutput("deTab"),
                                                            
                                                            downloadButton("DEdownload","Download Table")
                                                            #####
                                                            
                                                          )
                                                 ),
                                                 ####
                                                 tabPanel("Nanostring data table",
                                                          fluidPage(
                                                            h4("datatable"),
                                                            downloadButton("NANOdownload","Download Table"),
                                                            tableOutput('nanoTable'),
                                                            
                                                            
                                                          )),
                                                 #####https://shiny.rstudio.com/reference/shiny/1.2.0/showTab.html
                                                 #conditionalPanel(
                                                 #  condition = "input.gsDb != null",
                                                 
                                               
                            
                                                 
                                                 
                                                 #)
                                                 
                                                 
                                      )
                             ),
                             
                             ####
                             tabPanel("Gene Set Analysis",
                                      navbarPage("GSA", id = "gsa",
                                                 tabPanel("Gene Set Analysis",
                                                          fluidPage(
                                                            
                                                            #inputPanel(
                                                            
                                                            uiOutput("gsUI"),
                                                            #),
                                                            ###uiOutput(gsUI1)
                                                            ###Add another UI output and split up the index/q val threshold
                                                            ###Add a note for the minimum 
                                                            DTOutput("gsTab"),
                                                            
                                                            plotlyOutput("gsHM"),
                                                            
                                                            includeHTML("www/gsa.html"),
                                                            
                                                            textOutput('qvalue'),
                                                          )
                                                          
                                                 )
                                      )
                             ),
                             #####
                             tabPanel("Help",
                                      fluidPage(
                                        includeCSS("www/styling2.css"),
                                        includeHTML("www/help.html"),
                                        includeScript("www/styling2.js"),
                                      )
                                      
                                      ),
                             
                  )
)

)