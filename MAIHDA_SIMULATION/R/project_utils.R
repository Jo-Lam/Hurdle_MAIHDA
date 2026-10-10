# Project-level utilities for reproducible and auditable analysis runs.
#
# These helpers deliberately use base R so that dependency failures can be
# reported before the analysis packages are loaded.

find_project_root <- function(start = getwd()) {
  path <- normalizePath(start, winslash = "/", mustWork = TRUE)
  repeat {
    marker <- file.path(path, ".maihda-release")
    if (file.exists(marker)) return(path)
    parent <- dirname(path)
    if (identical(parent, path)) {
      stop("Could not locate the MAIHDA project root from: ", start, call. = FALSE)
    }
    path <- parent
  }
}

set_project_root <- function(start = getwd()) {
  root <- find_project_root(start)
  setwd(root)
  invisible(root)
}

assert_packages <- function(packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop(
      "Missing required packages: ", paste(missing, collapse = ", "),
      ". Install them before rerunning the analysis.",
      call. = FALSE
    )
  }
  invisible(packages)
}

parse_named_args <- function(args = commandArgs(trailingOnly = TRUE)) {
  out <- list()
  for (arg in args) {
    if (!startsWith(arg, "--") || !grepl("=", arg, fixed = TRUE)) {
      stop("Arguments must use --name=value syntax. Invalid argument: ", arg, call. = FALSE)
    }
    pair <- strsplit(sub("^--", "", arg), "=", fixed = TRUE)[[1]]
    key <- pair[[1]]
    value <- paste(pair[-1], collapse = "=")
    out[[gsub("-", "_", key, fixed = TRUE)]] <- value
  }
  out
}

arg_value <- function(args, name, default = NULL, type = c("character", "integer", "logical")) {
  type <- match.arg(type)
  value <- args[[name]]
  if (is.null(value)) return(default)
  if (type == "integer") {
    value <- suppressWarnings(as.integer(value))
    if (!is.finite(value)) stop("--", name, " must be an integer.", call. = FALSE)
  }
  if (type == "logical") {
    normalised <- tolower(value)
    if (!normalised %in% c("true", "false", "1", "0", "yes", "no")) {
      stop("--", name, " must be true or false.", call. = FALSE)
    }
    value <- normalised %in% c("true", "1", "yes")
  }
  value
}

make_run_id <- function(prefix) {
  paste0(prefix, "_", format(Sys.time(), "%Y%m%dT%H%M%S", tz = "UTC"))
}

normalise_run_dir <- function(path) {
  dir.create(path, recursive = TRUE, showWarnings = FALSE)
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

package_versions <- function(packages) {
  data.frame(
    package = packages,
    version = vapply(
      packages,
      function(x) if (requireNamespace(x, quietly = TRUE)) as.character(utils::packageVersion(x)) else NA_character_,
      character(1)
    ),
    stringsAsFactors = FALSE
  )
}

write_run_start <- function(output_dir, analysis, arguments, packages) {
  if (dir.exists(output_dir) && length(list.files(output_dir, all.files = TRUE, no.. = TRUE))) {
    stop("Run directory already exists and is not empty: ", output_dir, call. = FALSE)
  }
  output_dir <- normalise_run_dir(output_dir)
  metadata <- list(
    analysis = analysis,
    status = "running",
    started_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
    working_directory = normalizePath(getwd(), winslash = "/"),
    command = paste(commandArgs(), collapse = " "),
    arguments = arguments,
    random_seed_kind = RNGkind(),
    r_version = R.version.string,
    platform = R.version$platform
  )
  dput(metadata, file.path(output_dir, "run_config.dput"))
  utils::write.csv(package_versions(packages), file.path(output_dir, "package_versions.csv"), row.names = FALSE)
  writeLines(capture.output(utils::sessionInfo()), file.path(output_dir, "session_info.txt"))
  writeLines("running", file.path(output_dir, "RUNNING"))
  invisible(output_dir)
}

write_run_end <- function(output_dir, status = c("complete", "failed"), message = NULL) {
  status <- match.arg(status)
  running <- file.path(output_dir, "RUNNING")
  if (file.exists(running)) unlink(running)

  files <- list.files(output_dir, recursive = TRUE, full.names = TRUE, all.files = FALSE)
  files <- files[file.info(files)$isdir %in% FALSE]
  relative <- substring(normalizePath(files, winslash = "/"), nchar(normalizePath(output_dir, winslash = "/")) + 2L)
  inventory <- data.frame(
    file = relative,
    bytes = unname(file.info(files)$size),
    md5 = unname(tools::md5sum(files)),
    stringsAsFactors = FALSE
  )
  utils::write.csv(inventory, file.path(output_dir, "output_inventory.csv"), row.names = FALSE)

  record <- c(
    paste("status:", status),
    paste("finished_utc:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
    if (!is.null(message)) paste("message:", message)
  )
  writeLines(record, file.path(output_dir, if (status == "complete") "RUN_COMPLETE.txt" else "RUN_FAILED.txt"))
  invisible(inventory)
}

run_r_script <- function(script, args = character(), log_file, env = character()) {
  rscript <- file.path(R.home("bin"), "Rscript")
  command_args <- c("--vanilla", shQuote(normalizePath(script, winslash = "/", mustWork = TRUE)), args)
  status <- system2(rscript, command_args, stdout = log_file, stderr = log_file, env = env)
  if (!identical(status, 0L)) {
    stop("Analysis process failed with exit code ", status, ". See: ", log_file, call. = FALSE)
  }
  invisible(status)
}

