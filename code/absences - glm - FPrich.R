##############################################
# ANALYSIS OF CT & LI DUCKWEED SURVEY DATA   #
#                                            #
# Presence / Absence of floating plants      # 
# Importing data sets                        #
# Created: 07/14/2014 by MJ McCann           #
##############################################

data
dataENV
dataFP
dataNONFP
dataSPACE
dataSPECIES

head(data)
colnames(data)

######################################
# Define a full model                #
# log of predictor variables         #
# No interactions                    #
# excluded: depth_max_m, ALK_avg     #
# excluded: waterbodies_5km          #  
######################################
formula <- FP_presence ~ log(latitude) + log(longitude) + 
  log(surfacearea_ha) + log(shoreline_development) +
  log(nonFP_presence+1) + log(TOTP_avg) + 
  log(PH_avg) + log(COND_avg) + log(secchi_avg) + 
  log(waterbodies_1km+1) + log(waterbodies_10km) + 
  boatlaunch + log(dist_waterfowl+1) + log(nearest_LMSPW) # + 
  #log(nearest_SP) + log(nearest_W) + major_watershed + regional_watershed

glm_poisson_FPpresence_full_log <- glm(formula, family=poisson, data=data, na.action = "na.fail")

summary(glm_poisson_FPpresence_full_log)

# null model 
glm_binomial_FPpresence_null <- glm(FP_presence ~ 1, family=poisson, data=data, na.action = "na.fail")
summary(glm_binomial_FPpresence_null)

###############################
# Full model w/o interactions #
# log of predictor variables  #
# All sub-models              #
# Package: MuMIn              #
###############################
require(MuMIn)

# run all possible sub-models 
best_FPpresence_log <- dredge(glm_poisson_FPpresence_full_log)
best_FPpresence_log

# write the table of all sub-models to file 
numb_models <- nrow(best_FPpresence_log)
write.csv(best_FPpresence_log[1:numb_models],file="best_glm_FPpresence_log.csv",na="NA")

# Return the best model (lowest AIC)
get.models(best_FPpresence_log, 1)

# proportion deviance explained 
# Null Deviance:      233.5 
# Residual Deviance: 163.2 
d2 <- (233.5 - 163.2)/233.5

# adjusted proportion deviance explained 
# http://modtools.wordpress.com/2013/08/14/dsquared/
# d2_adj <- 1 - ((n - 1) / (n - p)) * (1 - d2)
# where n = # of observations and p = # of parameters (including the intercept)
n <- 174
p <- 8
d2_adj <- 1 - ((n - 1) / (n - p)) * (1 - d2)
d2_adj


# Visualize the model selection table:
plot(best_FPpresence_log)

# Model average models with delta AICc < 2
avg_FPpresence_log <- model.avg(best_FPpresence_log, subset = delta < 2)
summary(avg_FPpresence_log)
avg_FPpresence_log

# Alternatively, if I want standarzed coefficients 
model.avg(best_FPrich, subset = delta < 2, beta = TRUE)

# returns coefficients 
coef(avg_FPpresence_log)

# Relative importance values 
# Sum of ‘Akaike weights’ over all models including the explanatory variable
# These don't sum up to one (across all variables)
importance(best_FPpresence_log)


######################################
# Define a full model                #
# All pairwise interactions          #
# excluded: depth_max_m, ALK_avg     #
# excluded: waterbodies_5km          #
######################################
formula <- FP_presence ~ surfacearea_ha + shoreline_development + nonFP_presence + TOTP_avg + PH_avg + COND_avg + secchi_avg +
  waterbodies_1km +
  waterbodies_10km + 
  boatlaunch + 
  dist_waterfowl + 
  surfacearea_ha:shoreline_development                 +                                           
  surfacearea_ha:nonFP_presence                +                                           
  shoreline_development:nonFP_presence         +                                           
  surfacearea_ha:TOTP_avg                              +                                           
  shoreline_development:TOTP_avg                       +                                           
  nonFP_presence:TOTP_avg                      +                                           
  surfacearea_ha:PH_avg                                +                                           
  shoreline_development:PH_avg                         +                                           
  nonFP_presence:PH_avg                        +                                           
  TOTP_avg:PH_avg                                      +                                           
  surfacearea_ha:COND_avg                              +                                           
  shoreline_development:COND_avg                       +                                           
  nonFP_presence:COND_avg                      +                                           
  TOTP_avg:COND_avg                                    +                                           
  PH_avg:COND_avg                                      +                                           
  surfacearea_ha:secchi_avg                            +                                           
  shoreline_development:secchi_avg                     +                                           
  nonFP_presence:secchi_avg                    +                                           
  TOTP_avg:secchi_avg                                  +                                           
  PH_avg:secchi_avg                                    +                                           
  COND_avg:secchi_avg                                  +
  surfacearea_ha:waterbodies_1km                       + 
  shoreline_development:waterbodies_1km                + 
  nonFP_presence:waterbodies_1km               + 
  TOTP_avg + PH_avg:waterbodies_1km                    + 
  COND_avg:waterbodies_1km                             + 
  secchi_avg:waterbodies_1km                           +
  surfacearea_ha:waterbodies_10km                      + 
  shoreline_development:waterbodies_10km               + 
  nonFP_presence:waterbodies_10km              + 
  TOTP_avg + PH_avg:waterbodies_10km                   + 
  COND_avg:waterbodies_10km                            + 
  secchi_avg:waterbodies_10km                          +
  surfacearea_ha:boatlaunch                            + 
  shoreline_development:boatlaunch                     + 
  nonFP_presence:boatlaunch                    + 
  TOTP_avg + PH_avg:boatlaunch                         + 
  COND_avg:boatlaunch                                  + 
  secchi_avg:boatlaunch                                +
  surfacearea_ha:dist_waterfowl                        + 
  shoreline_development:dist_waterfowl                 + 
  nonFP_presence:dist_waterfowl                + 
  TOTP_avg + PH_avg:dist_waterfowl                     + 
  COND_avg:dist_waterfowl                              + 
  secchi_avg:dist_waterfowl                                

glm_poisson_FPpresence_full_interactions <- glm(formula, family=poisson, data=data, na.action = "na.fail")
summary(glm_poisson_FPpresence_full_interactions)

##############################
# Full model w/ interactions #
# All sub-models             #
# Package: MuMIn             #
##############################
require(MuMIn)

# run all possible sub-models 
best_FPpresence_interactions <- dredge(glm_poisson_FPpresence_full_interactions)
best_FPpresence_interactions

# write the table of all sub-models to file 
numb_models <- nrow(best_FPpresence_interactions)
write.csv(best_FPpresence_interactions[1:numb_models],file="best_FPpresence_interactions.csv",na="NA")

# Return the best model (lowest AIC)
get.models(best_FPpresence_interactions, 1)

# Visualize the model selection table:
plot(best_FPpresence_interactions)

# Model average models with delta AICc < 2
avg_FPpresence_interactions <- model.avg(best_FPpresence_interactions, subset = delta < 2)
summary(avg_FPpresence_interactions)
avg_FPpresence_interactions

# Alternatively, if I want standarzed coefficients 
model.avg(best_FPpresence_interactions, subset = delta < 2, beta = TRUE)

# returns coefficients 
coef(avg_FPpresence_interactions)

# Relative importance values 
# Sum of ‘Akaike weights’ over all models including the explanatory variable
# These don't sum up to one (across all variables)
importance(best_FPpresence_interactions)

######################################
# Define a full model                #
# No interactions                    #
# excluded: depth_max_m, ALK_avg     #
######################################
formula <- FP_presence ~ surfacearea_ha + shoreline_development + nonFP_presence + TOTP_avg + PH_avg + COND_avg + secchi_avg +
  waterbodies_1km +
  waterbodies_10km + 
  boatlaunch + 
  dist_waterfowl 
glm_poisson_FPpresence_full <- glm(formula, family=poisson, data=data, na.action = "na.fail")
summary(glm_poisson_FPpresence_full)

# try it with boatlaunch as a factor 
formula <- FP_presence ~ surfacearea_ha + shoreline_development + nonFP_presence + TOTP_avg + PH_avg + COND_avg + secchi_avg +
  waterbodies_1km +
  waterbodies_10km + 
  as.factor(boatlaunch) + 
  dist_waterfowl 
glm_poisson_FPpresence_full_2 <- glm(formula, family=poisson, data=data, na.action = "na.fail")
summary(glm_poisson_FPpresence_full_2)

###############################
# Full model w/o interactions #
# All sub-models              #
# Package: MuMIn              #
###############################
require(MuMIn)

# run all possible sub-models 
best_FPrich <- dredge(glm_poisson_FPpresence_full)
best_FPrich

# write the table of all sub-models to file 
numb_models <- nrow(best_FPrich)
write.csv(best_FPrich[1:numb_models],file="best_glm_FPrich.csv",na="NA")

# Return the best model (lowest AIC)
get.models(best_FPrich, 1)

# Visualize the model selection table:
plot(best_FPrich)

# Model average models with delta AICc < 2
avg_FPrich <- model.avg(best_FPrich, subset = delta < 2)
summary(avg_FPrich)
avg_FPrich

# Alternatively, if I want standarzed coefficients 
model.avg(best_FPrich, subset = delta < 2, beta = TRUE)

# returns coefficients 
coef(avg_FPrich)

# Relative importance values 
# Sum of ‘Akaike weights’ over all models including the explanatory variable
# These don't sum up to one (across all variables)
importance(best_FPrich)


# try it with boatlaunch as a factor 
best_FPpresence_2 <- dredge(glm_poisson_FPpresence_full_2)
best_FPpresence_2
plot(best_FPpresence_2)

##################
# Best model     #
# Y=FP rich      #
# X=cond, secchi #
##################
formula <- FP_presence ~ COND_avg + secchi_avg
glm_poisson_FPpresence_best <- glm(formula, family=poisson, data=data, na.action = "na.fail")
summary(glm_poisson_FPpresence_best)

# Check the significance of the residual deviance 
glm_poisson_FPpresence_best$df.resid # residual degrees of freedom
glm_poisson_FPpresence_best$deviance # deviance
1 - pchisq(185.2,171) # entered manually: p = 0.2167009
1 - pchisq(glm_poisson_FPpresence_best$deviance,glm_poisson_FPpresence_best$df.resid) # called by name: p = 0.2167009

# Check the overdispersion (should be close to 1)
glm_poisson_FPpresence_best$deviance/glm_poisson_FPpresence_best$df.resid

# residuals 
glm_poisson_FPpresence_best_resid <- resid(glm_poisson_FPpresence_best)
glm_poisson_FPpresence_best_resid <- as.vector(glm_poisson_FPpresence_best_resid)
glm_poisson_FPpresence_best_resid

# Output like an ANOVA table
anova(glm_poisson_FPpresence_best, test="Chisq")



