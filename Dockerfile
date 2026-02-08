FROM rocker/r-ver:4.3.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('plumber', 'xgboost'), repos='http://cran.us.r-project.org')"

WORKDIR /app
COPY api.R .
COPY xgboost_churn_model.rds .

EXPOSE 8000

CMD ["R", "-e", "plumber::plumb('api.R')$run(port=8000, host='0.0.0.0')"]
