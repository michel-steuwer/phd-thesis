require('ggplot2')

# replace | with newline
strwr <- function(str) gsub("\\|", "\n", str)

data <- read.table("loc.csv", header=TRUE, sep=",")


data$Benchmark <- strwr(data$Benchmark)

data$Benchmark <- factor(data$Benchmark,
                         levels = c("mandelbrot", "linear algebra\n(dot product)", "matrix\nmultiplication",
                                    "image processing\n(gaussian blur)", "medical imaging\n(LM OSEM)"))

# add empty column to store the sum of OpenCL lines
data <- cbind(data, Sums = c(0, recursive=TRUE))

# compute the sum of the OpenCL loc for every benchmark
for (b in levels(data$Benchmark)) {
  data[data$Benchmark == b,]$Sums <-
    sum(data[data$Program == "OpenCL" & data$Benchmark == b,]$Lines)
}

theme <- theme_bw() +
  theme(text = element_text(size = 16),
        axis.title = element_text(size = rel(1), vjust = 1),
        axis.text.x = element_text(size = rel(0.75)),
        legend.text = element_text(size = rel(0.85)),
        strip.text = element_text(size = rel(0.75)),
        panel.border = element_rect(linetype = "solid", colour = "black", size = 1.5),
        plot.margin = unit(c(0.25,0.25,0,0.25), 'cm'),
        legend.position="top",
        legend.title = element_blank(),
        strip.background = element_rect(colour = "black", fill = "white", size = 1.5))

labs <- labs(x = "", y = "Relative Lines of Code")

# create plot
plot <- ggplot(na.omit(data), aes(x=Program, y=Lines/Sums, fill=Device)) +
  geom_bar(color="black", width=.5, stat = "identity") +
  scale_fill_manual(values=c("#fdae6b", "#fee6ce")) + #"#e6550d", 
  scale_x_discrete() +
  scale_y_continuous(breaks=c(0, 0.15, 0.5, 1)) +
  facet_grid(. ~ Benchmark) + theme + labs

# save plot to file
ggsave(file = "summary_loc.pdf", width = 10, height = 4)

plot
