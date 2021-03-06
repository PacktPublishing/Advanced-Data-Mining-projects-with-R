
r_df<-read.csv("C:\\Users\\sandhyao\\Desktop\\R Data Mining Projects\\Section _6\\Wholesalecustomers.csv")

####Data Pre-processing
par(mfrow=c(2,3))
apply(r_df[,c(-1,-2)],2,boxplot)

#computing quantiles
quant<-function(x){quantile(x,probs=c(0.95,0.90,0.99))}
out1<-sapply(r_df[,c(-1,-2)],quant)

#removing outliers
r_df$Fresh<-ifelse(r_df$Fresh>=out1[2,1],out1[2,1],r_df$Fresh)

r_df$Milk<-ifelse(r_df$Milk>=out1[2,2],out1[2,2],r_df$Milk)

r_df$Grocery<-ifelse(r_df$Grocery>=out1[2,3],out1[2,3],r_df$Grocery)

r_df$Frozen<-ifelse(r_df$Frozen>=out1[2,4],out1[2,4],r_df$Frozen)

r_df$Detergents_Paper<-
  ifelse(r_df$Detergents_Paper>=out1[2,5],out1[2,5],r_df$Detergents_Paper)

r_df$Delicassen<-
  ifelse(r_df$Delicassen>=out1[2,6],out1[2,6],r_df$Delicassen)

#Checking outliers after removal
apply(r_df[,c(-1,-2)],2,boxplot)


r_df_scaled<-as.matrix(scale(r_df[,c(-1,-2)]))

head(r_df_scaled)

library(Rcmdr)

sumsq<-NULL
 
#Method 1

par(mfrow=c(1,2))
for (i in 1:15) sumsq[i] <-
  sum(KMeans(r_df_scaled,centers=i,iter.max=500,
             num.seeds=50)$withinss)

plot(1:15,sumsq,type="b", xlab="Number of Clusters",
      ylab="Within groups sum of squares",main="Screeplot using Rcmdr")

#Method 2

for (i in 1:15) sumsq[i] <-
  sum(kmeans(r_df_scaled,centers=i,iter.max=5000,
             algorithm = "Forgy")$withinss)

plot(1:15,sumsq,type="b", xlab="Number of Clusters",
      ylab="Within groups sum of squares",main="Screeplot using Stats")

#Kmeans Clustering
library(cluster);library(cclust)

set.seed(121)


km<-kmeans(r_df_scaled,centers=4,nstart=17,iter.max=50000,
           algorithm="Forgy",trace = T)

#checking results
summary(km)

km$centers

km$withinss

#attaching cluster information
Cluster<-cbind(r_df,Membership=km$cluster)
aggregate(Cluster[,3:8],list(Cluster[,9]),mean)

clusplot(Cluster, km$cluster, cex=0.9,color=TRUE, shade=TRUE,
         labels=4, lines=0)
#Predicting new data for KMeans

predict.kmeans <- function(km, r_df_scaled)
   {k <- nrow(km$centers)
   d <- as.matrix(dist(rbind(km$centers, r_df_scaled)))[-(1:k),1:k]
   n <- nrow(r_df_scaled)
   out <- apply(d, 1, which.min)
   return(out)}

#predicting cluster membership
 Cluster$Predicted<-predict.kmeans(km,r_df_scaled)
 
 table(Cluster$Membership,Cluster$Predicted)

#pmml code

library(pmml);
library(XML);

pmml(km)


#Hierarchical clustering 
 
hfit<-hclust(dist(r_df_scaled,method = "euclidean"),method="ward.D2")
par(mfrow=c(1,2))
plot(hfit,hang=-0.005,cex=0.7) 
 
hfit<-hclust(dist(r_df_scaled,method = "manhattan"),method="mcquitty")
par(mfrow=c(1,2))
plot(hfit,hang=-0.005,cex=0.7) 
 
hfit<-hclust(dist(r_df_scaled,method = "minkowski"))
plot(hfit,hang=-0.005,cex=0.7) 
 
hfit<-hclust(dist(r_df_scaled,method = "canberra"))
plot(hfit,hang=-0.005,cex=0.7)
 
summary(hfit) 


diana(x, diss = inherits(x, "dist"), metric = "euclidean", 
      stand = FALSE,keep.diss = n < 100,
      keep.data = !diss, trace.lev = 0)

dfit<-diana(r_df,diss=F,metric = "euclidean",stand=T,keep.data = F)

summary(dfit)
plot(dfit)

#cutting the tree into groups
 g_hfit<-cutree(hfit,k=4)
 plot(hfit)

table(g_hfit) 

rect.hclust(hfit,k=4,border = "blue")
#Model-based clustering

library(mclust)

clus <- Mclust(r_df[,-c(1,2)])

summary(clus)

#The clustering vector:
clus_vec <- clus$classification
clus_vec

clust <- lapply(1:3, function(nc) row.names(r_df)[clus_vec==nc])
clust # printing the clusters

summary(clus, parameters = T)


#Other cluster algorithms

library(kohonen)

som_grid <- somgrid(xdim = 20, ydim=20, topo="hexagonal")

som_model <- som(r_df_scaled,
                  grid=som_grid,
                  rlen=100,
                  alpha=c(0.05,0.01),
                  keep.data = TRUE,
                  n.hood="circular")

plot(som_model, type="changes",col="blue")

plot(som_model, type="count")

plot(som_model, type="dist.neighbours")

plot(som_model, type="codes")




