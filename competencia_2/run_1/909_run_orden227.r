# file.edit("~/.Rprofile")
# sudo chmod -R 777 /usr/local/lib/R/site-library

# Set the library path

# Function to install and load packages
check_install <- function(package) {
  if (!require(package, character.only = TRUE)) {
    install.packages(package, lib = "~/R/library", dependencies = TRUE)
    # library(package, character.only = TRUE)
  }
}

# List of packages to install
packages <- c("data.table", "ggplot2", "dplyr", "mice", "DiceKriging", "mlrMBO", "R.utils", "primes", "rlist", "mlflow")

# Install and load each package
for (pkg in packages) {
  check_install(pkg)
}

devtools::install_github("krlmlr/ulimit", "~/R/library")


require("rlang")

# workflow que voy a correr
PARAM <- "competencia_2/run_1/990_workflow_orden227_SEMI.r"

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
