# Deploy The Quote Desk to shinyapps.io.
# Builds a self-contained bundle: the app plus the engine's R files, so shinyapps.io
# does not need to install the inevitable package.
# Run from the project root:  source("deploy.R")

bundle <- file.path(tempdir(), "pricing-the-inevitable")
unlink(bundle, recursive = TRUE)
dir.create(file.path(bundle, "R"), recursive = TRUE)

app <- readLines("app/app.R")
start <- grep("# ENGINE-START", app, fixed = TRUE)
end <- grep("# ENGINE-END", app, fixed = TRUE)
app <- c(app[seq_len(start - 1)],
         'for (f in list.files("R", full.names = TRUE, pattern = "[.]R$")) source(f)',
         app[(end + 1):length(app)])
writeLines(app, file.path(bundle, "app.R"))
file.copy(list.files("R", full.names = TRUE), file.path(bundle, "R"))

rsconnect::deployApp(bundle, appName = "pricing-the-inevitable", forceUpdate = TRUE)
