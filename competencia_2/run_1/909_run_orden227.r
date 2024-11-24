# file.edit("~/.Rprofile")
# sudo chmod -R 777 /usr/local/lib/R/site-library
options(repos = c(CRAN = "https://cloud.r-project.org/"))

install.packages("data.table")
install.packages("rlist")
install.packages("mlflow")
install.packages("devtools")
install.packages("R.utils")
install.packages("primes")
install.packages("DiceKriging")
install.packages("ggplot2")
install.packages("mlrMBO")
devtools::install_github("krlmlr/ulimit")


require("rlang")

# workflow que voy a correr
PARAM <- "competencia_2/run_1/990_workflow_orden227_SEMI.r"

envg <- env()

envg$EXPENV <- list()
envg$EXPENV$repo_dir <- "~/dmeyf2024/competencia_2/run_1"

#------------------------------------------------------------------------------

correr_workflow <- function( wf_scriptname )
{
  dir.create( "~/tmp", showWarnings = FALSE)
  setwd("~/tmp" )

  # creo el script que corre el experimento
  comando <- paste0( 
      "#!/bin/bash\n", 
      "source /home/$USER/.venv/bin/activate\n",
      "nice -n 15 Rscript --vanilla ",
      envg$EXPENV$repo_dir,
      wf_scriptname,
      "   ",
      wf_scriptname,
     "\n",
     "deactivate\n"
    )
  cat( comando, file="run.sh" )

  Sys.chmod( "run.sh", mode = "744", use_umask = TRUE)

  system( "./run.sh" )
}
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

# aqui efectivamente llamo al workflow
correr_workflow( PARAM )
