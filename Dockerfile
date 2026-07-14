FROM rocker/r-ver:4.3.2

LABEL maintainer="ML Team"

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/* || { echo 'apt-get install failed'; exit 1; }

RUN R -e "tryCatch(install.packages(c('plumber', 'xgboost'), repos='http://cran.us.r-project.org'), error=function(e){quit(status=1)})"

WORKDIR /app
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

COPY --chown=appuser:appuser src/api.R /app/src/api.R
COPY --chown=appuser:appuser xgboost_churn_model.rds /app/

EXPOSE 8000

CMD ["R", "-e", "tryCatch(plumber::plumb('src/api.R')$run(port=8000, host='0.0.0.0'), error=function(e){quit(status=1)})"]
