# file.edit("~/.Rprofile")
# sudo chmod -R 777 /usr/local/lib/R/site-library
options(repos = c(CRAN = "https://cloud.r-project.org/"))

install.packages("data.table",lib="~/R/library")
install.packages("rlist",lib="~/R/library")
install.packages("mlflow",lib="~/R/library")
install.packages("devtools",lib="~/R/library")
install.packages("R.utils",lib="~/R/library")
install.packages("primes",lib="~/R/library")
install.packages("DiceKriging",lib="~/R/library")
install.packages("ggplot2",lib="~/R/library")
install.packages("mlrMBO",lib="~/R/library")

devtools::install_github("krlmlr/ulimit", lib="~/R/library")


require("rlang")

# workflow que voy a correr
PARAM <- "competencia_2/run_0/990_workflow_orden227_SEMI.r"

envg <- env()

envg$EXPENV <- list()
envg$EXPENV$repo_dir <- "~/dmeyf2024/"

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
