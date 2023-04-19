library(quantmod) 
library(ggplot2)
library(tseries)
library(forecast)

symbol ='AMZN'
to_date <- "2023-03-29"

# загружаем данные
AMAZON1 <- getSymbols(Symbols = symbol, from = '2022-03-29', to = to_date, src = "yahoo", auto.assign = FALSE)
ZOO1 <- zoo(AMAZON1$AMZN.Close, order.by=as.Date(as.character(index(AMAZON1)), format='%Y-%m-%d'))
amzn_ts1 <- ts(ZOO1)

AMAZON3 <- getSymbols(Symbols = symbol, from = '2020-03-29', to = to_date, src = "yahoo", auto.assign = FALSE)
ZOO3 <- zoo(AMAZON3$AMZN.Close, order.by=as.Date(as.character(index(AMAZON3)), format='%Y-%m-%d'))
amzn_ts3 <- ts(ZOO3)

AMAZON10 <- getSymbols(Symbols = symbol, from = '2013-03-29', to = to_date, src = "yahoo", auto.assign = FALSE)
ZOO10 <- zoo(AMAZON10$AMZN.Close, order.by=as.Date(as.character(index(AMAZON10)), format='%Y-%m-%d'))
amzn_ts10 <- ts(ZOO10)

AMZN_test <- getSymbols(Symbols = symbol, from = '2023-03-30', to = '2023-04-04', src = "yahoo", auto.assign = FALSE)
ZOO_test <- zoo(AMZN_test$AMZN.Close, order.by=as.Date(as.character(index(AMZN_test)), format='%Y-%m-%d'))
amzn_ts_test <- ts(ZOO_test)

# расчитываем доходности
amzn1_diff <- diff(amzn_ts1)
amzn3_diff <- diff(amzn_ts3)
amzn10_diff <- diff(amzn_ts10)

qplot(amzn1_diff, main='Распределение AMZN за 2022-2023')
qplot(amzn1_diff, main='Распределение AMZN за 2020-2023')
qplot(amzn1_diff, main='Распределение AMZN за 2013-2023')

# тест Дики-Фуллера
adf.test(amzn1_diff)
adf.test(amzn3_diff)
adf.test(amzn10_diff)

# AR Модель
amzn_ar <- arima(amzn_ts1, order = c(1, 0, 0))
amzn_ar

amzn_forecast <- predict(amzn_ar, n.ahead = 5)
amzn_forecast
amzn_ts_test

amzn_forecast_values <- amzn_forecast$pred
amzn_forecast_se <- amzn_forecast$se
plot.ts(amzn_ts1, main='Прогноз по AR для AMZN', xlab="№ наблюдения", ylab='Значение AMZN')
points(amzn_forecast_values , type = "l", col = 2)

# moving average model
amzn_ma <- arima(amzn_ts1, order = c(0, 0, 1))
amzn_ma

residuals <- residuals(amzn_ma)
amzn_fitted <- amzn_ts1 - residuals
ts.plot(amzn_ts1, main='Скользящее среднее', xlab="№ наблюдения", ylab='Значение AMZN')
points(amzn_fitted, type = "l", col = 2, lty = 2)

amzn_ma <- arima(amzn_ts1, order = c(0, 1, 1))
residuals <- residuals(amzn_ma)
amzn_fitted <- amzn_ts1 - residuals
ts.plot(amzn_ts1, main='Исправленное Скользящее среднее', xlab="№ наблюдения", ylab='Значение AMZN')
points(amzn_fitted, type = "l", col = 2, lty = 2)

amzn_forecast2 <- predict(amzn_ma, n.ahead = 5)
amzn_forecast2
amzn_forecast_values <- amzn_forecast2$pred


# arima (box-jenkins)
adf.test(amzn_ts)

acf(amzn_ts1)
pacf(amzn_ts1)

amzn_fit <- arima(amzn_ts1, order = c(1, 1, 0))
amzn_fit

amzn_forecast <- predict(amzn_fit , n.ahead = 3)
amzn_forecast

amzn_forecast_values <- amzn_forecast$pred
amzn_forecast_se <- amzn_forecast$se

plot.ts(amzn_ts1, main='ARIMA для AMZN', xlab="№ наблюдения", ylab='Значение AMZN')
points(amzn_forecast_values , type = "l", col = 2)
amzn_fitted_data <- amzn_ts1 - residuals(amzn_fit)
points(amzn_fitted_data, type = "l", col = 4, lty = 2)

# auto arima
amzn_fit_auto <- auto.arima(amzn_ts1)
amzn_fit_auto

amzn_fit <- arima(amzn_ts1, order = c(1, 1, 4))
amzn_forecast <- predict(amzn_fit, n.ahead = 3)
amzn_forecast
amzn_forecast_values <- amzn_forecast$pred
plot.ts(amzn_ts1, main='Auto ARIMA для AMZN', xlab="№ наблюдения", ylab='Значение AMZN')
points(amzn_forecast_values , type = "l", col = 4, lty = 2)
