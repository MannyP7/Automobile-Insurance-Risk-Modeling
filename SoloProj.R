# Load the data
#insurance <- read.csv("https://raw.githubusercontent.com/nmeraihi/data/master/ausprivauto0405.csv")
insurance <- read.csv("ausprivauto0405.csv")
dim(insurance)
str(insurance)
summary(insurance)

# Check for missing values
colSums(is.na(insurance))

# Check for invalid entries
sum(insurance$Exposure <= 0)
sum(insurance$ClaimNb < 0)

# Convert categorical variables to factors
insurance$VehAge <- factor(insurance$VehAge)
insurance$VehBody <- factor(insurance$VehBody)
insurance$Gender <- factor(insurance$Gender)
insurance$DrivAge <- factor(insurance$DrivAge)

# Verify the changes
str(insurance)

# Examine each category
table(insurance$DrivAge)
table(insurance$VehAge)
table(insurance$ClaimNb) # over 90% 0 claims so lambda should be small -> check mean & var

#should be close
mean(insurance$ClaimNb)
var(insurance$ClaimNb)
#we see its around 6% larger which could mean overdispersion

#comparison of observed and expected poisson
observed <- as.numeric(table(insurance$ClaimNb))
observed - nrow(insurance) * dpois(0:4, mean(insurance$ClaimNb))

#calc claim frequency total claim / total exposure
Tclaim <- aggregate(ClaimNb ~ DrivAge, data = insurance, FUN = sum)
TExposure <- aggregate(Exposure ~ DrivAge, data = insurance, FUN = sum)

Tclaim$ClaimNb / TExposure$Exposure

#slap it on the table
Tclaim$Frequency <- Tclaim$ClaimNb / TExposure$Exposure

#same but for VehAge

Tclaim2 <- aggregate(ClaimNb ~ VehAge, data = insurance, FUN = sum)
TExposure2 <- aggregate(Exposure ~ VehAge, data = insurance, FUN = sum)
Tclaim2$ClaimNb / TExposure2$Exposure
Tclaim2$Frequency <- Tclaim2$ClaimNb / TExposure2$Exposure

#now combine
Tclaim3 <- aggregate(ClaimNb ~ DrivAge + VehAge, data = insurance, FUN = sum)
TExposure3 <- aggregate(Exposure ~ DrivAge + VehAge, data = insurance, FUN = sum)
Tclaim3$Frequency <- Tclaim3$ClaimNb / TExposure3$Exposure
Tclaim3

# Create matrix of claim frequencies
freq_matrix <- xtabs(Frequency ~ VehAge + DrivAge, data = Tclaim3)

# Create grouped bar graph
barplot(freq_matrix,
        beside = TRUE,
        col = c("steelblue", "skyblue", "orange", "tomato"),
        legend.text = TRUE,
        args.legend = list(x = "topright", cex = 0.7),
        xlab = "Driver Age",
        ylab = "Claims per Policy-Year",
        main = "Claim Frequency by Driver Age and Vehicle Age",
        las = 2,
        cex.names = 0.7,
        ylim = c(0, 0.30))

#The youngest drivers consistently have higher
#observed claim frequencies than the oldest drivers, regardless of vehicle age

#Young cars generally have higher claim frequencies than old or oldest cars

# lets fit
#Baseline model using only exposure

m1 <- glm(ClaimNb ~ Exposure, data = insurance, family = poisson)
summary(m1)
# summary answers:
#   log(mew) = -3.59 + 1.79Exposure
#   p value super small so reject null hypothesis that the intercept is zero
#   hence Exposure is a significant predictor
#   AIC = 34908

m2 <- glm(ClaimNb ~ Exposure + DrivAge + VehAge, data = insurance, family = poisson)
summary(m2)
# summary answers:
#   Pvalues 
#
#
#

anova(m1, m2, test = "Chisq")
#we are checking whether the added predictors are significant all together
#we got small pvalue so reject null that they all have a zero coefficient 
#so all together are significant


m3 <- glm(ClaimNb ~ Exposure + DrivAge + VehAge + DrivAge:VehAge, data = insurance, family = poisson)
summary(m3)
# summary answers:
#   Pvalues 
#
#
#

anova(m2, m3, test = "Chisq")
#big pvalue so we fail to reject the null
#We don't have sufficient statistical evidence that
#the association between driver age and expected claim counts depends on vehicle age 
#after accounting for exposure.


#check residual plots
plot(predict(m2, type = "response"),
     residuals(m2, type = "deviance"),
     xlab = "Predicted Claims",
     ylab = "Deviance Residuals",
     main = "Residuals vs Fitted (M2)")
abline(h = 0, col = "red", lty = 2)
# looks fine: each curve represents one of the claim mumbers 

m2_quasi <- glm(ClaimNb ~ Exposure + DrivAge + VehAge,data = insurance,family = quasipoisson)
summary(m2_quasi)

# "Dispersion parameter for quasipoisson family taken to be 1.016707"
# hence very mild overdispersion

BIC(m1,m2,m3)

#Select M2 
summary(m2)
confint(m2)

exp(confint(m2))

#DrivAgeoldest people has 1 in the exp(confint()) so statistically insignificant
# same with VehAgeoldest cars and VehAgeyoungest cars

results <- data.frame(Estimate=exp(coef(m2)), LowerCI = exp(confint(m2)[,1]), UpperCI = exp(confint(m2)[,2]), Pvalue = summary(m2)$coefficients[,4])

round(results,4)

data.frame(AIC = AIC(m1, m2, m3)$AIC,BIC = BIC(m1, m2, m3)$BIC,row.names = c("M1", "M2", "M3"))






#AI made---------------

# Extract exponentiated coefficients and 95% confidence intervals
est <- exp(coef(m2))
ci <- exp(confint(m2))

# Remove intercept and Exposure
est <- est[-c(1, 2)]
ci <- ci[-c(1, 2), ]

# Shorten predictor labels
names(est) <- c(
  "Older working drivers",
  "Oldest drivers",
  "Working-age drivers",
  "Young drivers",
  "Youngest drivers",
  "Oldest cars",
  "Young cars",
  "Youngest cars"
)

# Increase left margin to prevent labels being cut off
par(mar = c(5, 12, 4, 2))

# Set positions for each coefficient
y <- seq_along(est)

# Create coefficient plot
plot(est, y,
     xlim = range(c(1, ci)),
     ylim = c(0.5, length(est) + 0.5),
     yaxt = "n",
     pch = 19,
     col = "darkgreen",
     xlab = "Expected Claim Count Ratio",
     ylab = "",
     main = "M2: Estimated Effects with 95% CI")

# Add horizontal confidence intervals
segments(ci[, 1], y,
         ci[, 2], y,
         col = "darkgreen",
         lwd = 2)

# Add predictor labels
axis(2, at = y,
     labels = names(est),
     las = 2,
     cex.axis = 0.8)

# Add reference line at 1
abline(v = 1, col = "red", lty = 2)

# Reset margins
par(mar = c(5, 4, 4, 2))
#---------------