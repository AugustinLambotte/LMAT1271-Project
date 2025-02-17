################################################################################
#                                                                              #
#                              LMAT 1271                                       #
#                           Projet 2022-2023                                   #
#         Auteurs : Marie Determe, Augustin Lambotte, Amaury Laridon           #
#         Script R utiliser pour le projet instructions et ressources          #
#       disponibles à : https://github.com/AmauryLaridon/LMAT1271-Project      #
#                                                                              #
################################################################################

rm(list=ls(all=TRUE)) # Nettoyage mémoire R Studio
set.seed(2023)

######################### - Partie 1.3 Simulations - ###########################

n <- 400 # size of the sampling
nbr_replication <- 100 # number of replication of the sampling process
a_0 <- 0.5 # alpha parameter of the density function of T
b_0 <- 1.2 # beta parameter of the density function of T

#Density function of random variable T
f_a_0b_0 <- function(t) {
  if(t > 0 & t < 1) {
    return(a_0*b_0*t^(a_0-1)*(1-t^a_0)^(b_0-1))
  } else {
    return(0)
  }
}

#Quantile of order p, a and b are unknown parameters
q_p_a_b <- function(p,a,b) {
  return ((1-(1-p)^(1/b))^(1/a))
}

#Quantile of order p
q_p <- function(p) {
  return (q_p_a_b(p,a_0,b_0))
}

#First estimator of q_0.95
q_s <- function(T_i) {
  size <- length(T_i)
  T_sort <- sort(T_i)
  return (T_sort[ceiling(0.95*size)]+(T_sort[floor(0.95*size)]
                        -T_sort[ceiling(0.95*size)])*(0.95*n-ceiling(0.95*n)))
}

#Estimator of a_m and b_m, using the method of moments
q_m <- function(T_i) {
  #On cherche une racine à la première équation de 1.2.b pour obtenir 
  #a_M, puis on calcule b_M et q_M
  f1 <- function(a) {
    return ((sum(T_i^(2*a)))*(n+sum(T_i^(a)))*(sum(T_i^(a)))^(-2)-2)
  }
  solution <- uniroot(f1,c(1e-9,10))
  a_m <- solution$root
  b_m <- n/(sum(T_i^(a_m)))-1
  return (q_p_a_b(0.95,a_m,b_m))
}

#Estimator of a_l and b_l, using the maximum likelihood estimator
q_l <- function(T_i) {
  #On cherche une racine à la première équation de 1.2.c pour obtenir a_L
  #puis on calcule b_L et q_L
  f1 <- function(a) {
    return (1/a + (1/(sum(log(1-T_i^a)))+(1/n))*sum((T_i^(a)
                                  *log(T_i))/(1-T_i^(a)))+(1/n)*sum(log(T_i)))
  }
  solution_l <- uniroot(f1,c(1e-9,10))
  a_l <- solution_l$root
  b_l <- -n/(sum(log(1-T_i^(a_l))))
  
  return (q_p_a_b(0.95,a_l,b_l))
}

### - 1.3 (a) - ###

#Generation of a iid sample of size 20 from the density f_a_0b_0 and 
#estimation of q_0.95 in 3 different ways
generate_sample <- function() {
  U <- runif(n)
  T_i <- sapply(U,q_p)
  q_s_sample <- q_s(T_i)
  q_m_sample <- q_m(T_i)
  q_l_sample <- q_l(T_i)
  return (c(q_s_sample,q_m_sample,q_l_sample))
}

### - 1.3 (b) - ###

generate_estimation_q_p <- function(affichage) {
  estimation_q_p <- replicate(nbr_replication,generate_sample())
  estimation_q_s <- estimation_q_p[1,]
  estimation_q_m <- estimation_q_p[2,]
  estimation_q_l <- estimation_q_p[3,]
  
  
### - 1.3 (c) - ###
  
  #Approximation de l'espérance par la moyenne empirique
  esperance_q_s <- mean(estimation_q_s)
  esperance_q_m <- mean(estimation_q_m)
  esperance_q_l <- mean(estimation_q_l)
  
  #Calcul du biais
  bias_s <- esperance_q_s - q_p_true
  bias_m <- esperance_q_m - q_p_true
  bias_l <- esperance_q_l - q_p_true
  
  #Calcul de la variance
  variance_s <- mean(estimation_q_s^2)-esperance_q_s^2
  variance_m <- mean(estimation_q_m^2)-esperance_q_m^2
  variance_l <- mean(estimation_q_l^2)-esperance_q_l^2
  
  #Calcul du MSE
  mse_s <- bias_s^2 + variance_s
  mse_m <- bias_m^2 + variance_m
  mse_l <- bias_l^2 + variance_l

  if (affichage == TRUE) {
    hist(estimation_q_s,breaks=10, main="")
    title(main = paste("Histogram of estimated q_s\n", "n =", n, " N =", 
        nbr_replication, " a_0 =", a_0, " b_0 =", b_0), sub= paste("Biais =", 
        round(bias_s, digits=4)  , " Variance=", round(variance_s, digits=4), 
        " MSE=", round(mse_s, digits=4)))
    boxplot(estimation_q_s, xlab = "q_s", ylab="Value")
    title(main = paste("Boxplot of estimated q_s\n","n =", n, " N =", 
        nbr_replication, " a_0 =", a_0, " b_0 =", b_0), sub= paste("Biais =", 
        round(bias_s, digits=4)  , " Variance=", round(variance_s, digits=4), 
        " MSE=", round(mse_s, digits=4)))
    
    
    hist(estimation_q_m,breaks=10, main = "")
    title(main = paste("Histogram of estimated q_m\n","n =", n, " N =", 
        nbr_replication, " a_0 =", a_0, " b_0 =", b_0), sub= paste("Biais =", 
        round(bias_m, digits=4)  , " Variance=", round(variance_m, digits=4), 
        " MSE=", round(mse_m, digits=4)))
    boxplot(estimation_q_m, xlab = "q_m", main = "", ylab="Value")
    title(main = paste("Boxplot of estimated q_m\n","n =", n, " N =", 
        nbr_replication, " a_0 =", a_0, " b_0 =", b_0), sub= paste("Biais =", 
        round(bias_m, digits=4)  , " Variance=", round(variance_m, digits=4), 
        " MSE=", round(mse_m, digits=4)))
    
    
    hist(estimation_q_l,breaks=10, main = "")
    title(main = paste("Histogram of estimated q_l\n","n =", n, " N =", 
        nbr_replication, " a_0 =", a_0, " b_0 =", b_0), 
        sub= paste("Biais =", round(bias_l, digits=4)  , 
        " Variance=", round(variance_l, digits=4), 
        " MSE=", round(mse_l, digits=4)))
    boxplot(estimation_q_l, xlab = "q_l" , main = "", ylab="Value")   
    title(main = paste("Boxplot of estimated q_l\n","n =", n, " N =", 
        nbr_replication, " a_0 =", a_0, " b_0 =", b_0), 
        sub= paste("Biais =", round(bias_l, digits=4)  , " Variance=", 
        round(variance_l, digits=4), " MSE=", round(mse_l, digits=4)))
    
  }
  
  return (c(c(bias_s,bias_m,bias_l),
            c(variance_s,variance_m,variance_l),c(mse_s,mse_m,mse_l)))
}

#################### - Execution - ######################

#Vraie valeur de q_0.95
q_p_true <- q_p(0.95)

#1.3.a
generate_sample()

#1.3.b et 1.3.c
generate_estimation_q_p(TRUE)

